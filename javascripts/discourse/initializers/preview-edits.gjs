import { trustHTML } from "@ember/template";
import { apiInitializer } from "discourse/lib/api";
import { getURLWithCDN } from "discourse/lib/get-url";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import loadScript from "discourse/lib/load-script";
import { resizeAllGridItems } from "../lib/gridupdate";
import PreviewsDetails from "./../components/previews-details";
import PreviewsThumbnail from "./../components/previews-thumbnail";
import PreviewsTilesThumbnail from "./../components/previews-tiles-thumbnail";

const PLUGIN_ID = "discourse-tc-topic-list-previews";
const INTERACTIVE_TILE_SELECTOR = [
  "a",
  "button",
  "input",
  "label",
  "select",
  "textarea",
  "[role='button']",
  "[role='link']",
  ".avatar",
  ".badge-category",
  ".badge-category__wrapper",
  ".badge-notification",
  ".badge-posts",
  ".badge-wrapper",
  ".discourse-tag",
  ".discourse-tags",
  ".topic-actions",
  ".topic-category",
  ".topic-status",
  ".topic-statuses",
].join(",");

const previewsTilesThumbnail = <template>
  <PreviewsTilesThumbnail @topic={{@topic}} />
</template>;

const previewsDetails = <template>
  <PreviewsDetails @topic={{@topic}} />
</template>;

function destinationUrl(topic) {
  if (topic.force_latest_post_nav && topic.last_post_id) {
    return `/t/${topic.slug}/${topic.id}/${topic.last_post_id}`;
  }

  const topicUrl =
    topic.linked_post_number && typeof topic.urlForPostNumber === "function"
      ? topic.urlForPostNumber(topic.linked_post_number)
      : topic.lastUnreadUrl;

  return topicUrl || topic.url;
}

export default apiInitializer("0.8", (api) => {
  const siteSettings = api.container.lookup("service:site-settings");
  const topicListPreviewsService = api.container.lookup(
    "service:topic-list-previews"
  );
  const supportsGridLanes = CSS.supports('display: grid-lanes');

  if (!supportsGridLanes) {
    console.warn(
      "TLP: your browser does not support CSS Grid Lanes. Topic List Previews will fall back to a standard grid layout approximation for masonry. Please consider updating your browser for the best experience."
    );

    api.onPageChange(() => {
      loadScript(getURLWithCDN(settings.theme_uploads.imagesloaded)).then(() => {
        if (document.querySelector(".tiles-style")) {
          //eslint-disable-next-line no-undef
          imagesLoaded(
            document.querySelector(".tiles-style"),
            resizeAllGridItems()
          );
        }
      });
    });

    // Keep track of the last "step" of 400 pixels.
    let lastIndex = 0;

    // Some browsers do some strange things with off-screen images,
    // so we need to resize the grid items when we scroll.
    // Listen for scroll events.
    window.addEventListener("scroll", () => {
      // Calculate the current index (which 400-pixel block we are in)
      const currentIndex = Math.floor(window.scrollY / 400);
      // If we've moved into a new block, call the function.
      if (currentIndex !== lastIndex) {
        lastIndex = currentIndex;
        resizeAllGridItems();
      }
    });
  }

  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (topicListPreviewsService.displayTiles) {
      columns.delete("activity");
      columns.delete("replies");
      columns.delete("views");
      columns.delete("posters");
      columns.delete("topic");
    }
    return columns;
  });

  api.registerValueTransformer("topic-list-item-mobile-layout", ({ value }) => {
    if (topicListPreviewsService.displayTiles) {
      // Force the desktop layout
      return false;
    }
    return value;
  });

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value, context }) => {
      if (topicListPreviewsService.displayTiles) {
        value.push("tiles-style");
      }
      if (
        topicListPreviewsService.displayThumbnails &&
        (context.topic.thumbnails?.length > 0 ||
          (settings.topic_list_default_thumbnail_fallback &&
            settings.topic_list_default_thumbnail !== ""))
      ) {
        value.push("has-thumbnail");
      }
      if (settings.topic_list_tiles_larger_featured_tiles) {
        if (context.topic?.tags.some((t) => settings.topic_list_featured_images_tag.includes(t.name))) {
          value.push("featured-topic");
        }
      }
      if (
        siteSettings.topic_list_enable_thumbnail_colour_determination &&
        topicListPreviewsService.displayThumbnails
      ) {
        let red = context.topic.dominant_colour?.red || 0;
        let green = context.topic.dominant_colour?.green || 0;
        let blue = context.topic.dominant_colour?.blue || 0;

        //make 1 the minimum value to avoid total black
        red = red === 0 ? 1 : red;
        green = green === 0 ? 1 : green;
        blue = blue === 0 ? 1 : blue;

        let averageIntensity = context.topic.dominant_colour
          ? (red + green + blue) / 3
          : null;

        if (
          Object.keys(context.topic?.dominant_colour).length === 0 ||
          !(
            settings.topic_list_dominant_color_background === "always" ||
            (topicListPreviewsService.displayTiles &&
              settings.topic_list_dominant_color_background === "tiles only")
          )
        ) {
          value.push("no-background-colour");
        } else if (averageIntensity > 127) {
          value.push("dark-text");
        } else {
          value.push("white-text");
        }
      } else {
        value.push("no-background-colour");
      }

      return value;
    }
  );

  api.registerValueTransformer(
    "topic-list-item-style",
    ({ value, context }) => {
      if (
        siteSettings.topic_list_enable_thumbnail_colour_determination &&
        topicListPreviewsService.displayThumbnails &&
        (settings.topic_list_dominant_color_background === "always" ||
          (topicListPreviewsService.displayTiles &&
            settings.topic_list_dominant_color_background === "tiles only")) &&
        Object.keys(context.topic?.dominant_colour).length !== 0
      ) {
        let red = context.topic.dominant_colour?.red || 0;
        let green = context.topic.dominant_colour?.green || 0;
        let blue = context.topic.dominant_colour?.blue || 0;

        //make 1 the minimum value to avoid total black
        red = red === 0 ? 1 : red;
        green = green === 0 ? 1 : green;
        blue = blue === 0 ? 1 : blue;

        let newRgb = "rgb(" + red + "," + green + "," + blue + ")";

        value.push(trustHTML(`background: ${newRgb};`));
      }
      return value;
    }
  );

  api.registerValueTransformer("topic-list-class", ({ value }) => {
    if (topicListPreviewsService.displayTiles) {
      value.push("tiles-style");
      if (settings.topic_list_tiles_wide_format) {
        value.push("side-by-side");
      }
    }
    return value;
  });

  api.renderInOutlet(
    "topic-list-before-link",
    <template>
      {{#unless topicListPreviewsService.displayTiles}}
        {{#if topicListPreviewsService.displayThumbnails}}
          <div class="topic-thumbnail">
            <PreviewsThumbnail @tiles={{false}} @topic={{@outletArgs.topic}} />
          </div>
        {{/if}}
      {{/unless}}
    </template>
  );

  api.registerValueTransformer("topic-list-item-expand-pinned", ({ value }) => {
    if (
      !topicListPreviewsService.displayTiles &&
      topicListPreviewsService.displayExcerpts
    ) {
      return true;
    }
    return value; // Return default value
  });

  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (
      topicListPreviewsService.displayTiles &&
      topicListPreviewsService.displayThumbnails
    ) {
      columns.add(
        "previews-thumbnail",
        { item: previewsTilesThumbnail },
        { before: "topic" }
      );
    }
    if (topicListPreviewsService.displayTiles) {
      columns.add(
        "previews-details",
        { item: previewsDetails },
        { after: "topic" }
      );
    }
    return columns;
  });

  api.registerBehaviorTransformer(
    "topic-list-item-click",
    ({ next, context }) => {
      if (!topicListPreviewsService.displayTiles) {
        return next();
      }

      const result = next();
      const { event, navigateToTopic, topic } = context;
      const target = event
        .composedPath()
        .find((element) => element instanceof Element);

      if (
        event.defaultPrevented ||
        wantsNewWindow(event) ||
        !target ||
        typeof navigateToTopic !== "function" ||
        target.closest(INTERACTIVE_TILE_SELECTOR)
      ) {
        return result;
      }

      event.preventDefault();
      navigateToTopic(topic, destinationUrl(topic));

      return result;
    }
  );

  api.modifyClass("component:search-result-entries", {
    pluginId: PLUGIN_ID,
    tagName: "div",
    classNameBindings: ["thumbnailGrid:thumbnail-grid"],

    thumbnailGrid() {
      return siteSettings.topic_list_search_previews_enabled;
    },
  });

  api.modifyClass("component:search-result-entry", {
    pluginId: PLUGIN_ID,

    thumbnailGrid() {
      return siteSettings.topic_list_search_previews_enabled;
    },
  });
});
