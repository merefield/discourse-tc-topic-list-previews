import Component from "@glimmer/component";
import TlpFeaturedTopics from "./tlp-featured-topics";

export default class TlpFeaturedTopicsPlacementComponent extends Component {
  get shouldRender() {
    return (
      settings.topic_list_featured_images_placement === this.args.placement
    );
  }

  <template>
    {{#if this.shouldRender}}
      <TlpFeaturedTopics @category={{@category}} />
    {{/if}}
  </template>
}
