from robot.api.deco import keyword

@keyword("Merge Two Lists")
def merge_lists(list1, list2):
    set1 = set(list1)
    set2 = set(list2)
    final_list = set1

    for i2 in set2:
        if i2 not in set1:
            final_list.add(i2)

    return final_list
