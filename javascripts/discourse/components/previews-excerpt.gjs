import { service } from "@ember/service";
import Component from "@glimmer/component";

export default class PreviewsExcerpt extends Component {
  @service topicListPreviews;

  get showExcerpt() {
    return this.topicListPreviews.displayExcerpts;
  }

  <template>
    {{!-- {{#if this.showExcerpt}} --}}
      <a href='{{@topic.url}}'>
        {{@topic.excerpt}}
      </a>
    {{!-- {{/if}} --}}
  </template>
}