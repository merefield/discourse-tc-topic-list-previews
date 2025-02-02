import { service } from "@ember/service";
import Component from "@glimmer/component";
import TopicExcerpt from "discourse/components/topic-list/topic-excerpt";

export default class PreviewsExcerpt extends Component {
  @service topicListPreviews;

  get showExcerpt() {
    return this.topicListPreviews.displayExcerpts;
  }

  <template>
    {{#if this.showExcerpt}}
      <TopicExcerpt @topic={{@topic}} />
    {{/if}}
  </template>
}
