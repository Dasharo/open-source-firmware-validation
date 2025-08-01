# SPDX-FileCopyrightText: 2025 Michał Iwanicki <iwanicki92@gmail.com>
#
# SPDX-License-Identifier: Apache-2.0

from robot.api.deco import library
from robot.api.interfaces import ListenerV3
from robot.libraries.BuiltIn import BuiltIn
from robot.model.keyword import Keyword
from robot.model.tags import Tags
from robot.model.testsuite import TestSuite
from robot.running.model import TestCase


@library(scope="SUITE", version="7.1", listener="SELF")
class TemplateSplit(ListenerV3):
    """Generates separate tests for templates"""

    ROBOT_LISTENER_API_VERSION = 3

    def __init__(
        self,
        *,
        setup_template: bool = False,
        copy_tags: bool = True,
        add_count_prefix: bool = True,
        custom_prefix: str = "",
    ):
        """Generates separate tests for templates

        Args:
            setup_template (bool, optional): Run Test Setup/Teardown keywords \
                for template. When set to False only generated tests will run \
                Test Setup and Test Teardown. Defaults to False.
            copy_tags (bool, optional): Should test created from template have \
                the same tags as template. Defaults to True.
            add_count_prefix (bool, optional): Adds test number to generated test \
                name. Count is only incremented when generating new templated test. \
                Defaults to True.
            custom_prefix (str, optional): Add this prefix before test number. \
                Test name ends up as '<custom_prefix><count>: <template_keyword>. \
                Used only if add_count_prefix is True. Defaults to empty string
        """
        super().__init__()
        self.setup_template = setup_template
        self.copy_tags = copy_tags
        self.add_prefix = add_count_prefix
        self.custom_prefix = custom_prefix
        self.suite: TestSuite | None = None
        self.test: TestCase | None = None
        self.setup: Keyword | None = None
        self.teardown: Keyword | None = None
        self.tags: Tags | None = None
        self.count = 1

    def start_test(self, data, result):
        if data.template:
            self.test = data
            self.setup = self.test.setup
            self.teardown = self.test.teardown
            if not self.setup_template:
                self.test.setup = None
                self.test.teardown = None
            if self.copy_tags:
                self.tags = data.tags

    def end_test(self, data, result):
        self.test = None
        self.setup = None
        self.teardown = None
        self.tags = None

    def start_user_keyword(self, data, implementation, result):
        if self.test and data != self.setup and result.status != "NOT RUN":
            keyword_name = BuiltIn().replace_variables(data.name)
            if self.add_prefix:
                new_test_name = f"{self.custom_prefix}{self.count:03}: {keyword_name}"
            else:
                new_test_name = str(keyword_name)
            new_test: TestCase = self.test.parent.tests.create(
                new_test_name, tags=self.tags
            )
            new_test.body.create_keyword(keyword_name, args=data.args)
            if self.setup:
                new_test.setup.config(name=self.setup.name, args=self.setup.args)
            if self.teardown:
                new_test.teardown.config(
                    name=self.teardown.name, args=self.teardown.args
                )
            implementation.body.clear()
            implementation.body.create_keyword(
                "Log", [f"Created test: {new_test_name}"]
            )
            self.count += 1
