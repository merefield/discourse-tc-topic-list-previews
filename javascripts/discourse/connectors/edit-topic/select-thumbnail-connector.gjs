import SelectThumbnail from "../../components/select-thumbnail";

<template>
  {{#if @outletArgs.model.sidecar_installed}}
    <SelectThumbnail
      @topic_id={{@outletArgs.model.id}}
      @topic_title={{@outletArgs.model.title}}
      @buffered={{@outletArgs.buffered}}
    />
  {{/if}}
</template>
