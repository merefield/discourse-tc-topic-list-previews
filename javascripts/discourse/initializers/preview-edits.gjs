import { apiInitializer } from "discourse/lib/api";
import SortableColumn from "discourse/components/topic-list/header/sortable-column";
import { service } from "@ember/service";
import PreviewsThumbnail from "./../components/previews-thumbnail";
// import PreviewsMeta from "./../components/previews-meta";
// import PreviewsUsers from "./../components/previews-users";
// import PreviewsExcerpt from "./../components/previews-excerpt";
// import PreviewsActions from "./../components/previews-actions";
// import PreviewsFooter from "./../components/previews-footer";
import PreviewsDetails from "./../components/previews-details";
import { resizeAllGridItems } from "../lib/gridupdate";
import loadScript from "discourse/lib/load-script";


const PLUGIN_ID = "topic-list-previews";

// const previewsActions = <template>
//   <PreviewsActions @topic={{@topic}}/>
// </template>;

const previewsThumbnail = <template>
  <PreviewsThumbnail @thumbnails={{@topic.thumbnails}}/>
</template>;

// const previewsMeta = <template>
//   <PreviewsMeta @topic={{@topic}}/>
// </template>;

// const previewsExcerpt = <template>
//   <div class="topic-excerpt">
//       {{@topic.excerpt}}
//   </div>
// </template>;

// const previewsPosters = <template>
//     <PreviewsUsers @topic={{@topic}}/>
// </template>;

// const previewsFooter = <template>
//     <PreviewsFooter @topic={{@topic}}/>
// </template>;

const previewsDetails = <template>
    <PreviewsDetails @topic={{@topic}}/>
</template>;


export default apiInitializer("0.8", (api) => {
  const router = api.container.lookup("service:router");
  const currentUser = api.container.lookup("service:current-user");
  const topicListPreviewsService = api.container.lookup("service:topic-list-previews");
  //   api.onPageChange(() => {
  //   loadScript(
  //     settings.theme_uploads.imagesloaded
  //   ).then(() => {
  //     if (document.querySelector(".tiles-style")) {
  //       imagesLoaded(
  //         document.querySelector(".tiles-style"),
  //         resizeAllGridItems()
  //       );
  //     }
  //   });
  // });
  api.registerValueTransformer(
    "topic-list-columns",
    ({ value: columns }) => {
      console.log("topicListPreviewsService", topicListPreviewsService);
      if (topicListPreviewsService.displayTiles) {
        // debugger;
        columns.delete("activity");
        columns.delete("replies");
        columns.delete("views");
        columns.delete("posters");
        columns.delete("topic");
      };
      // }
      return columns;
    }
  );

api.registerValueTransformer(
  "topic-list-item-class",
  ({ value, context }) => {
    if (topicListPreviewsService.displayThumbnails) {
      value.push("tiles-style");
    }
    return value;
  }
)

api.registerValueTransformer(
  "topic-list-class",
  ({ value, context }) => {
    if (topicListPreviewsService.displayThumbnails) {
      value.push("tiles-style");
      if (settings.topic_list_tiles_wide_format) {
        value.push("side-by-side");
      }
    }

    return value;
  }
)

api.registerValueTransformer(
    "topic-list-columns",
    ({ value: columns }) => {
      if (topicListPreviewsService.displayThumbnails) {
        columns.add("previews-thumbnail",
         { item: previewsThumbnail },
          { before: "topic" }
        )
      };
      // if (topicListPreviewsService.displayExcerpts) {
      //   columns.add("previews-excerpt",
      //    { item: previewsExcerpt },
      //     { after: "topic" }
      //   )
      // };
      // columns.add("previews-meta",
      //    { item: previewsMeta },
      //     { after: "previews-excerpt" }
      //   )
      if (topicListPreviewsService.displayTiles) {
        columns.add("previews-details",
          { item: previewsDetails },
            { after: "topic" }
          )
      }
        // columns.add("previews-actions",
        //  { item: previewsActions },
        //   { after: "previews-posters" }
        // )
      // columns.add("previews-",
      //    { item: previewsPosters },
      //     { after: "topic" }
      //   )
      // }
      return columns;
    }
  );
});

