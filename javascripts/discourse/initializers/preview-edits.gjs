import { apiInitializer } from "discourse/lib/api";
import SortableColumn from "discourse/components/topic-list/header/sortable-column";
import { service } from "@ember/service";
import PreviewsThumbnail from "./../components/previews-thumbnail";
import PreviewsTilesThumbnail from "./../components/previews-tiles-thumbnail";
import PreviewsDetails from "./../components/previews-details";
import { resizeAllGridItems } from "../lib/gridupdate";
import loadScript from "discourse/lib/load-script";

const PLUGIN_ID = "topic-list-previews";

const previewsTilesThumbnail = <template>
    <PreviewsTilesThumbnail @thumbnails={{@topic.thumbnails}}/>
</template>;

const previewsThumbnailHeader = <template>
  <th>blah</th>
</template>;

const previewsDetails = <template>
  <PreviewsDetails @topic={{@topic}}/>
</template>;

export default apiInitializer("0.8", (api) => {
  const router = api.container.lookup("service:router");
  const currentUser = api.container.lookup("service:current-user");
  const topicListPreviewsService = api.container.lookup("service:topic-list-previews");

       api.onPageChange(() => {
        loadScript(
          settings.theme_uploads.imagesloaded
        ).then(() => {
          if (document.querySelector(".tiles-style")) {
            imagesLoaded(
              document.querySelector(".tiles-style"),
              resizeAllGridItems()
            );
          }
        });
      });

  api.registerValueTransformer(
    "topic-list-columns",
    ({ value: columns }) => {
      console.log("topicListPreviewsService", topicListPreviewsService);
      if (topicListPreviewsService.displayTiles) {
        columns.delete("activity");
        columns.delete("replies");
        columns.delete("views");
        columns.delete("posters");
        columns.delete("topic");
      };
      return columns;
    }
  );

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value, context }) => {
      if (topicListPreviewsService.displayTiles) {
        value.push("tiles-style");
      }
      return value;
    }
  )

  api.registerValueTransformer(
    "topic-list-class",
    ({ value, context }) => {
      if (topicListPreviewsService.displayTiles) {
        value.push("tiles-style");
        if (settings.topic_list_tiles_wide_format) {
          value.push("side-by-side");
        }
      }
      return value;
    }
  )

  api.renderInOutlet("topic-list-before-link", <template>
    {{#unless topicListPreviewsService.displayTiles}}
      {{#if topicListPreviewsService.displayThumbnails}}
        <div class="topic-thumbnail">
          <PreviewsThumbnail @thumbnails={{@outletArgs.topic.thumbnails}} @tiles={{false}} />
        </div>
      {{/if}}
    {{/unless}}
  </template>);

  api.registerValueTransformer(
      "topic-list-item-expand-pinned",
      ({ value, context }) => {
        // const overrideEverywhere =
        //   enabledCategories.length === 0 && enabledTags.length === 0;
        // const overrideInCategory = enabledCategories.includes(
        //   discovery.category?.id
        // );
        // const overrideInTag = enabledTags.includes(discovery.tag?.id);
        // const overrideOnDevice = context.mobileView
        //   ? settings.show_excerpts_mobile
        //   : settings.show_excerpts_desktop;

        if (!topicListPreviewsService.displayTiles && topicListPreviewsService.displayExcerpts) {
          return true;
        }
        return value; // Return default value
      }
    );

api.registerValueTransformer(
    "topic-list-columns",
    ({ value: columns }) => {
      if (topicListPreviewsService.displayTiles) {
        columns.add("previews-thumbnail", 
          { item: previewsTilesThumbnail },
          { before: "topic" }
        )
      };
      if (topicListPreviewsService.displayTiles) {
        columns.add("previews-details",
          { item: previewsDetails },
            { after: "topic" }
          )
      }
      return columns;
    }
  );
});

