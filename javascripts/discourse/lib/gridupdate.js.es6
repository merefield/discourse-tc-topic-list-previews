import loadScript from 'discourse/lib/load-script';

// window.addEventListener ('scroll', resizeAllGridItems);

// let isResizing = false; // Prevent infinite loops

// window.addEventListener('scroll', () => {
//   if (!isResizing) {
//     resizeAllGridItems();
//   }
// });

function resizeGridItem (item, grid, rowHeight, rowGap) {
  loadScript (
    settings.theme_uploads.imagesloaded
  ).then (() => {
    imagesLoaded (item, function () {
      console.log('resizeGridItem', item);
      // const contentHeight = item.getBoundingClientRect().height;

      let contentHeight = 0;
      // debugger;
      console.log(item.children);
      console.log(item.children.length);
      Array.from(item.children).forEach(child => {
        contentHeight +=  child.getBoundingClientRect().height;
        // child.getBoundingClientRect().height;
      });
      // debugger;
      let rowSpan = Math.ceil (
        (contentHeight + rowGap) / (rowHeight + rowGap)
      );
      if (rowSpan !== rowSpan) {
        rowSpan = 1;
      }
      item.style.gridRowEnd = 'span ' + rowSpan;
    });
  });
}

// function resizeGridItem(item, grid, rowHeight, rowGap) {
//   loadScript(settings.theme_uploads.imagesloaded).then(() => {
//     imagesLoaded(item, function () {
//       console.log('resizeGridItem');

//       let children = Array.from(item.children).filter(child => 
//         child.offsetParent !== null // Ignore hidden elements
//       );

//       if (children.length === 0) {
//         item.style.gridRowEnd = 'span 1';
//         return;
//       }

//       // Get the first and last child's bounding boxes
//       const firstChild = children[0].getBoundingClientRect();
//       const lastChild = children[children.length - 1].getBoundingClientRect();

//       // Calculate total height from first to last child
//       let contentHeight = lastChild.bottom - firstChild.top;

//       let rowSpan = Math.ceil((contentHeight + rowGap) / (rowHeight + rowGap));
//       if (isNaN(rowSpan) || rowSpan < 1) {
//         rowSpan = 1;
//       }

//       item.style.gridRowEnd = 'span ' + rowSpan;
//     });
//   });
// }


function resizeAllGridItems () {
  // if (isResizing) return; // Prevent re-entrant calls
  // isResizing = true;

  const allItems = document.getElementsByClassName ('topic-list-item');
  let grid = false;

  grid = document.getElementsByTagName('tbody')[0];

  if (!grid) {
    return;
  }
  const rowHeight = parseInt (
    window.getComputedStyle (grid).getPropertyValue ('grid-auto-rows')
  );
  const rowGap = parseInt (
    window.getComputedStyle (grid).getPropertyValue ('grid-row-gap')
  );
  for (var x = 0; x < allItems.length; x++) {
    resizeGridItem (allItems[x], grid, rowHeight, rowGap);
  }
  // isResizing = false;
}

export {resizeAllGridItems};
