import Component from "@glimmer/component";
import TlpFeaturedTopics from "./tlp-featured-topics";

export default class TlpFeaturedTopicsPlacementComponent extends Component {
  get featuredImagesEnabled() {
    return this.args.category
      ? settings.topic_list_featured_images_category
      : settings.topic_list_featured_images;
  }

  get shouldRender() {
    return (
      settings.topic_list_featured_images_placement === this.args.placement &&
      this.featuredImagesEnabled &&
      settings.topic_list_featured_images_tag.trim().length > 0
    );
  }

  <template>
    {{#if this.shouldRender}}
      <TlpFeaturedTopics @category={{@category}} />
    {{/if}}
  </template>
}
