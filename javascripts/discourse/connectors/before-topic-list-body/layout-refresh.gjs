import Component from "@glimmer/component";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { resizeGridItems } from "../../lib/gridupdate";

export default class LayoutRefresh extends Component {
  @service topicListPreviews;

  attachResizeObserver = modifier((element) => {
    const topicList = element.closest(".topic-list");
    const topicListBody = topicList?.querySelector("tbody");
    const listArea = document.getElementById("list-area");

    if (!topicList || !topicListBody) {
      // eslint-disable-next-line no-console
      console.error(
        "topic-list-previews resize-observer requires a topic-list body"
      );
      return;
    }

    let animationFrame = null;
    let resizeAll = false;
    const pendingItems = new Set();

    const triggerResize = (item) => {
      if (item && !resizeAll) {
        pendingItems.add(item);
      } else {
        resizeAll = true;
        pendingItems.clear();
      }

      if (animationFrame !== null) {
        return;
      }

      animationFrame = requestAnimationFrame(() => {
        animationFrame = null;
        const items = resizeAll ? null : pendingItems;
        const isSideBySide =
          topicList?.classList.contains("side-by-side") &&
          listArea &&
          listArea.offsetWidth > 900;

        resizeGridItems(topicList, isSideBySide, items);
        resizeAll = false;
        pendingItems.clear();
      });
    };

    const observedWidths = new WeakMap([
      [topicList, topicList.getBoundingClientRect().width],
    ]);
    if (listArea) {
      observedWidths.set(listArea, listArea.getBoundingClientRect().width);
    }

    const onResize = (entries) => {
      for (const entry of entries) {
        const width = entry.contentRect.width;
        if (width !== observedWidths.get(entry.target)) {
          observedWidths.set(entry.target, width);
          triggerResize();
          break;
        }
      }
    };

    const onImageComplete = (event) => {
      if (!(event.target instanceof HTMLImageElement)) {
        return;
      }

      const item = event.target.closest(".topic-list-item");
      if (item && topicListBody.contains(item)) {
        triggerResize(item);
      }
    };

    const resizeObserver = new ResizeObserver(onResize);
    resizeObserver.observe(topicList);
    if (listArea) {
      resizeObserver.observe(listArea);
    }

    const mutationObserver = new MutationObserver((mutationsList) => {
      for (const mutation of mutationsList) {
        if (mutation.type === "childList") {
          triggerResize();
          break;
        }
      }
    });

    mutationObserver.observe(topicListBody, { childList: true });
    topicListBody.addEventListener("load", onImageComplete, true);
    topicListBody.addEventListener("error", onImageComplete, true);

    // Size the initial list immediately. Images which are still loading will
    // update their own item through the captured load/error handlers above.
    triggerResize();

    return () => {
      if (animationFrame !== null) {
        cancelAnimationFrame(animationFrame);
      }
      resizeObserver.disconnect();
      mutationObserver.disconnect();
      topicListBody.removeEventListener("load", onImageComplete, true);
      topicListBody.removeEventListener("error", onImageComplete, true);
    };
  });

  get fallbackNoCSSMasonry() {
    if (
      this.topicListPreviews.displayTiles &&
      !CSS.supports("display: grid-lanes")
    ) {
      return true;
    }
    return false;
  }

  <template>
    {{#if this.fallbackNoCSSMasonry}}
      <div class="resize-watcher" {{this.attachResizeObserver}}></div>
    {{/if}}
  </template>
}
