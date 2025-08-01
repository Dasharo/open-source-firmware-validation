# SPDX-FileCopyrightText: 2025 Michał Iwanicki <iwanicki92@gmail.com>
#
# SPDX-License-Identifier: Apache-2.0

from collections.abc import Callable
from pathlib import Path
from typing import Any, TypeAlias

from robot.api.deco import keyword, library
from robot.api.exceptions import Error
from robot.libraries.BuiltIn import BuiltIn
from robot.model.testsuite import TestSuite
from robot.running.namespace import IMPORTER, Namespace
from robot.running.resourcemodel import ResourceFile
from robot.utils.robottypes import is_truthy
from robot.variables.resolvable import Resolvable
from robot.variables.variables import Variables

PlatformVariableName: TypeAlias = str
PlatformVariableValue: TypeAlias = Any
PlatformVariables: TypeAlias = dict[PlatformVariableName, PlatformVariableValue]
PlatformName: TypeAlias = str


@library(scope="TEST", version="5.0")
class PlatformParser:
    # Used with 'Get DTS' keywords
    SKIP_PLATFORMS = [
        "qemu",  # requires /tmp/qmp-socket file to exist
        "qemu-selftests",  # requires /tmp/qmp-socket file to exist
        "no-rte",  # not a platform?
        "novacustom-ts1",  # requires INSTALLED_DUT variable to be set
    ]

    @keyword("Get DTS Test Platform Names")
    def get_dts_test_platform_names(self) -> list[PlatformName]:
        """Returns list of platforms (filename without extension) that support
        DTS testing. Checks all robot files in 'platform-configs' except ones
        defined in SKIP_PLATFORMS in this class

        Returns:
            list[str]: list of platforms that support DTS testing
        """
        return [platform for platform, _ in self._get_dts_test_platforms()]

    @keyword("Get DTS Test Variables")
    def get_dts_test_variables(self) -> dict[PlatformName, PlatformVariables]:
        """Parses all files in 'platform-configs` except ones defined in
        SKIP_PLATFORMS into dictionary with keys being a platform name and value
        being dict of DTS_TEST_* variables.

        Returns:
            dict[PlatformName, PlatformVariables]: dict with DTS test variables: \
                {<platform_name>: {<variable_name>: <variable_value>}}
        """
        platforms = self._get_dts_test_platforms()
        platform_variables: dict[PlatformName, PlatformVariables] = {}
        for platform, namespace in platforms:
            variables = self._get_variables_by_name(
                namespace, lambda name: name.startswith("DTS_TEST")
            )
            platform_variables[platform] = variables
        return platform_variables

    @keyword("Get Platform Variables")
    def get_platform_variables(self, platform: PlatformName) -> PlatformVariables:
        """Parse {platform}.robot in platform-configs and return dict containing
        platform variables. Global variables are included but overwritten by
        platform if it also defines them

        Args:
            platform (PlatformName): platform filename without extension

        Returns:
            PlatformVariables: dict with variables
        """
        root = Path(BuiltIn().get_variable_value("${EXECDIR}"))
        platform_path = root / f"platform-configs/{platform}.robot"
        platform_namespace = self._get_resource(platform_path)
        if not platform_namespace:
            raise Error(f"Couldn't parse {platform_path}, it isn't a file")
        self._update_namespace_with_global_vars(platform_namespace)
        return self._get_variables_from_namespace(platform_namespace)

    def _get_dts_test_platforms(self) -> list[tuple[PlatformName, Namespace]]:
        """Returns list of platforms that support DTS testing.
        Checks all robot files in 'platform-configs' and parses each one into
        Namespace containing all resources (e.g. variables)

        Returns:
            list[tuple[PlatformName, Namespace]]: list of platforms that support
            DTS testing. Each tuple contains robot filename without extension and
            parsed resource returned as a Namespace
        """
        root = Path(BuiltIn().get_variable_value("${EXECDIR}"))
        platform_dir = root / "platform-configs"
        dts_test_platforms = []
        for platform in platform_dir.glob("*.robot"):
            if platform.stem in self.SKIP_PLATFORMS:
                continue
            platform_namespace = self._get_resource(platform)
            if not platform_namespace:
                continue
            self._update_namespace_with_global_vars(platform_namespace)
            if is_truthy(self._get_variable_value(platform_namespace, "DTS_SUPPORT")):
                dts_test_platforms.append((platform.stem, platform_namespace))
        return dts_test_platforms

    def _get_resource(self, platform: Path) -> Namespace | None:
        """Parse platform file into Namespace containing e.g. variables

        Args:
            platform (Path): Path to platform robot file to parse

        Returns:
            Namespace | None: Parsed namespace or None if path was not a file
        """
        if not platform.is_file():
            return None
        resource: ResourceFile = IMPORTER.import_resource(str(platform))
        platform_namespace = Namespace(
            variables=Variables(),
            suite=TestSuite(f"Temporary {platform.stem} namespace"),
            resource=resource,
            languages=None,
        )
        platform_namespace.variables.set_from_variable_section(resource.variables)
        platform_namespace.handle_imports()
        return platform_namespace

    def _get_variables_from_namespace(self, namespace: Namespace) -> PlatformVariables:
        """Turn namespace into resolved variables that can be used in tests

        Args:
            namespace (Namespace): namespace to turn into PlatformVariables

        Returns:
            PlatformVariables: dict with variables defined in platform config
        """
        namespace.variables.resolve_delayed()
        return namespace.variables.as_dict()

    def _get_variable_value(
        self, namespace: Namespace, variable_name: str
    ) -> PlatformVariableValue | None:
        """Return resolved value of variable or None if no variable defined

        Args:
            namespace (Namespace): Namespace from which to take variable
            variable_name (str): Variable name

        Returns:
            PlatformVariableValue | None: Variable value or None if variable
            doesn't exist
        """
        namespace_variables = namespace.variables
        variables = namespace_variables.store.data
        if variable_name in variables:
            var = variables[variable_name]
            if isinstance(var, Resolvable):
                return var.resolve(namespace_variables)
            else:
                return var

        return None

    def _get_variables_by_name(
        self, namespace: Namespace, predicate: Callable[[str], bool]
    ) -> PlatformVariables:
        """Return all variables whose keys fulfiill predicate

        Args:
            namespace (Namespace): namespace from which to get variables
            predicate (Callable[[str], bool]): predicate used to filter variables

        Returns:
            PlatformVariables: variables that fulfill predicate
        """
        filtered_variables: PlatformVariables = {}
        for variable_name in namespace.variables.store:
            if not predicate(variable_name):
                continue
            resolved_value = self._get_variable_value(namespace, variable_name)
            if resolved_value is not None:
                filtered_variables[variable_name] = resolved_value
        return filtered_variables

    def _update_namespace_with_global_vars(
        self, namespace: Namespace, global_overwrite: bool = False
    ):
        """Used so variables like ${FALSE} can be resolved. Adds global
        variables to namespace.

        Args:
            namespace (Namespace): Namespace to which add global vars
            global_overwrite (bool, optional): whether global variables should
            overwrite platform ones if both contain the same variable
        """
        variable_store = namespace.variables.store
        if global_overwrite:
            variable_store.update(BuiltIn()._variables._global.store)
        else:
            global_variables = BuiltIn()._variables._global.copy()
            global_variables.store.update(variable_store)
            variable_store.update(global_variables.store)
