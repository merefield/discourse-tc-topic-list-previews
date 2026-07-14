function resizeGridItem(item, isSideBySide, rowHeight, rowGap) {
  let contentHeight = 0;

  if (isSideBySide) {
    // Only use the height of the first child
    const firstChild = item.children[0];
    if (firstChild) {
      contentHeight = firstChild.getBoundingClientRect().height;
    }
  } else {
    // Sum all children's heights
    for (const child of item.children) {
      contentHeight += child.getBoundingClientRect().height;
    }
  }

  const rowSpan = Math.max(
    1,
    Math.ceil((contentHeight + rowGap) / (rowHeight + rowGap)) || 1
  );

  return { item, rowSpan };
}

function resizeGridItems(topicList, isSideBySide, items) {
  const grid = topicList.querySelector("tbody");

  if (!grid) {
    return;
  }

  const rowHeight = parseInt(
    window.getComputedStyle(grid).getPropertyValue("grid-auto-rows"),
    10
  );
  const rowGap = parseInt(
    window.getComputedStyle(grid).getPropertyValue("grid-row-gap"),
    10
  );

  const gridItems = items
    ? Array.from(items).filter((item) => grid.contains(item))
    : Array.from(grid.getElementsByClassName("topic-list-item"));

  // Read all layout values before writing styles to avoid forced reflows between
  // individual topic-list items.
  const updates = gridItems.map((item) =>
    resizeGridItem(item, isSideBySide, rowHeight, rowGap)
  );

  for (const { item, rowSpan } of updates) {
    const gridRowEnd = `span ${rowSpan}`;
    if (item.style.gridRowEnd !== gridRowEnd) {
      item.style.gridRowEnd = gridRowEnd;
    }
  }
}

export { resizeGridItems };
