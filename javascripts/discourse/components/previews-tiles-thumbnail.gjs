import PreviewsThumbnail from "./previews-thumbnail";

<template>
  <div class="topic-thumbnail">
    <PreviewsThumbnail
      @url={{@url}}
      @thumbnails={{@thumbnails}}
      @tiles={{true}}
    />
  </div>
</template>
