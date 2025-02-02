import { apiInitializer } from "discourse/lib/api";
import SortableColumn from "discourse/components/topic-list/header/sortable-column";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import PreviewsThumbnail from "./../components/previews-thumbnail";
import PreviewsTilesThumbnail from "./../components/previews-tiles-thumbnail";
import PreviewsDetails from "./../components/previews-details";
import { resizeAllGridItems } from "../lib/gridupdate";
import loadScript from "discourse/lib/load-script";

const PLUGIN_ID = "topic-list-previews";

const previewsTilesThumbnail = <template>
  <PreviewsTilesThumbnail
    @url={{@topic.url}}
    @thumbnails={{@topic.thumbnails}}
  />
</template>;

const previewsDetails = <template>
  <PreviewsDetails @topic={{@topic}} />
</template>;

export default apiInitializer("0.8", (api) => {
  const router = api.container.lookup("service:router");
  const currentUser = api.container.lookup("service:current-user");
  const siteSettings = api.container.lookup("service:site-settings");
  const topicListPreviewsService = api.container.lookup(
    "service:topic-list-previews"
  );

  api.onPageChange(() => {
    loadScript(settings.theme_uploads.imagesloaded).then(() => {
      if (document.querySelector(".tiles-style")) {
        imagesLoaded(
          document.querySelector(".tiles-style"),
          resizeAllGridItems()
        );
      }
    });
  });

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
        context.topic.thumbnails?.length > 0
      ) {
        value.push("has-thumbnail");
      }
      if (siteSettings.topic_list_enable_thumbnail_colour_determination) {
        let red = context.topic.dominant_colour?.red || 0;
        let green = context.topic.dominant_colour?.green || 0;
        let blue = context.topic.dominant_colour?.blue || 0;

        //make 1 the minimum value to avoid total black
        red = red == 0 ? 1 : red;
        green = green == 0 ? 1 : green;
        blue = blue == 0 ? 1 : blue;

        let newRgb = "rgb(" + red + "," + green + "," + blue + ")";

        let averageIntensity = context.topic.dominant_colour
          ? (red + green + blue) / 3
          : null;

        if (Object.keys(context.topic?.dominant_colour).length === 0) {
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
        Object.keys(context.topic?.dominant_colour).length !== 0
      ) {
        let red = context.topic.dominant_colour?.red || 0;
        let green = context.topic.dominant_colour?.green || 0;
        let blue = context.topic.dominant_colour?.blue || 0;

        //make 1 the minimum value to avoid total black
        red = red == 0 ? 1 : red;
        green = green == 0 ? 1 : green;
        blue = blue == 0 ? 1 : blue;

        let newRgb = "rgb(" + red + "," + green + "," + blue + ")";

        value.push(htmlSafe(`background: ${newRgb};`));
      }
      return value;
    }
  );

  api.registerValueTransformer("topic-list-class", ({ value, context }) => {
    if (topicListPreviewsService.displayTiles) {
      value.push("tiles-style");
      if (settings.topic_list_tiles_wide_format) {
        value.push("side-by-side");
      }
    }
    return value;
  });

  api.renderInOutlet("topic-list-before-link", <template>
    {{#unless topicListPreviewsService.displayTiles}}
      {{#if topicListPreviewsService.displayThumbnails}}
        <div class="topic-thumbnail">
          <PreviewsThumbnail
            @thumbnails={{@outletArgs.topic.thumbnails}}
            @tiles={{false}}
          />
        </div>
      {{/if}}
    {{/unless}}
  </template>);

  api.registerValueTransformer(
    "topic-list-item-expand-pinned",
    ({ value, context }) => {
      if (
        !topicListPreviewsService.displayTiles &&
        topicListPreviewsService.displayExcerpts
      ) {
        return true;
      }
      return value; // Return default value
    }
  );

  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (topicListPreviewsService.displayTiles) {
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
});
