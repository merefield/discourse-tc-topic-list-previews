import Component from "@glimmer/component";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";

export default class PreviewsExcerpt extends Component {
  @service topicListPreviews;

  get showExcerpt() {
    return this.topicListPreviews.displayExcerpts;
  }

  get destinationUrl() {
    if (this.args.topic.force_latest_post_nav && this.args.topic.last_post_id) {
      return `/t/${this.args.topic.slug}/${this.args.topic.id}/${this.args.topic.last_post_id}`;
    } else {
      return this.args.topic.url;
    }
  }

  get excerpt() {
    return this.args.topic.show_latest_post_excerpt
      ? htmlSafe(this.args.topic.last_post_excerpt)
      : htmlSafe(this.args.topic.excerpt);
  }

  <template>
    {{#if this.showExcerpt}}
      <a class="topic-excerpt" href={{this.destinationUrl}}>
        {{this.excerpt}}
      </a>
    {{/if}}
  </template>
}
