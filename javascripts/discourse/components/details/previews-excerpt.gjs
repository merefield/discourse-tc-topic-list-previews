import Component from "@glimmer/component";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";

export default class PreviewsExcerpt extends Component {
  @service topicListPreviews;

  get showExcerpt() {
    return this.topicListPreviews.displayExcerpts;
  }

  get destinationUrl() {
    const topic = this.args.topic;

    if (topic.force_latest_post_nav && topic.last_post_id) {
      return `/t/${topic.slug}/${topic.id}/${topic.last_post_id}`;
    }

    const topicUrl =
      topic.linked_post_number && typeof topic.urlForPostNumber === "function"
        ? topic.urlForPostNumber(topic.linked_post_number)
        : topic.lastUnreadUrl;

    return topicUrl || topic.url;
  }

  get excerpt() {
    return this.args.topic.show_latest_post_excerpt
      ? trustHTML(this.args.topic.last_post_excerpt)
      : trustHTML(this.args.topic.excerpt);
  }

  <template>
    {{#if this.showExcerpt}}
      <a class="topic-excerpt" href={{this.destinationUrl}}>
        {{this.excerpt}}
      </a>
    {{/if}}
  </template>
}
