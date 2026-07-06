import PreviewsThumbnail from "./previews-thumbnail";

export default class PreviewsTilesThumbnail extends PreviewsThumbnail {
  <template>
    <div class="topic-thumbnail">
      <PreviewsThumbnail @topic={{@topic}} @tiles={{true}} />
    </div>
  </template>
}
