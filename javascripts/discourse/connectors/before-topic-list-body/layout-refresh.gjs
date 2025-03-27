import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { resizeAllGridItems } from "../../lib/gridupdate";

export default class LayoutRefresh extends Component {
  @service topicListPreviews;

  @tracked isResizing = false; // Prevent infinite loops

  attachResizeObserver = modifier((element) => {
    const topicList = element.closest(".topic-list");
    const listArea = document.getElementById("list-area");

    if (!topicList) {
      // eslint-disable-next-line no-console
      console.error(
        "topic-list-previews resize-observer must be inside a topic-list"
      );
      return;
    }

    let lastWidth = topicList.offsetWidth;

    // Function to trigger resize
    const triggerResize = () => {
      if (this.isResizing) {
        return;
      }
      requestAnimationFrame(() => {
        this.isResizing = true;
        let isSideBySide =
          topicList?.classList.contains("side-by-side") &&
          listArea &&
          listArea.offsetWidth > 900;
        resizeAllGridItems(isSideBySide);
        this.isResizing = false;
      });
    };

    Window.triggerResize = triggerResize;

    // Observe width changes
    const onResize = () => {
      const newWidth = topicList.offsetWidth;
      if (newWidth !== lastWidth) {
        lastWidth = newWidth;
        triggerResize();
      }
    };

    const resizeObserver = new ResizeObserver(onResize);
    resizeObserver.observe(topicList);

    // Observe child mutations (added/removed elements)
    const mutationObserver = new MutationObserver((mutationsList) => {
      for (let mutation of mutationsList) {
        if (mutation.type === "childList") {
          triggerResize(); // Resize when children change
          break; // No need to check further mutations in this cycle
        }
      }
    });

    mutationObserver.observe(topicList, { childList: true });

    return () => {
      resizeObserver.disconnect();
      mutationObserver.disconnect();
    };
  });

  <template>
    {{#if this.topicListPreviews.displayTiles}}
      <div class="resize-watcher" {{this.attachResizeObserver}}></div>
    {{/if}}
  </template>
}
