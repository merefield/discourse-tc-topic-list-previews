import loadScript from "discourse/lib/load-script";

function resizeGridItem(item, isSideBySide, rowHeight, rowGap) {
  loadScript(settings.theme_uploads.imagesloaded).then(() => {
    //eslint-disable-next-line no-undef
    imagesLoaded(item, function () {
      let contentHeight = 0;

      if (isSideBySide) {
        // Only use the height of the first child
        let firstChild = item.children[0];
        if (firstChild) {
          contentHeight = firstChild.getBoundingClientRect().height;
        }
      } else {
        // Sum all children's heights
        Array.from(item.children).forEach((child) => {
          contentHeight += child.getBoundingClientRect().height;
        });
      }

      let rowSpan = Math.ceil((contentHeight + rowGap) / (rowHeight + rowGap));
      if (rowSpan !== rowSpan) {
        rowSpan = 1;
      }
      item.style.gridRowEnd = "span " + rowSpan;
    });
  });
}

function resizeAllGridItems(isSideBySide) {
  const allItems = document.getElementsByClassName("topic-list-item");
  let grid = false;

  grid = document.getElementsByTagName("tbody")[0];

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
  for (let x = 0; x < allItems.length; x++) {
    resizeGridItem(allItems[x], isSideBySide, rowHeight, rowGap);
  }
}

export { resizeAllGridItems };
