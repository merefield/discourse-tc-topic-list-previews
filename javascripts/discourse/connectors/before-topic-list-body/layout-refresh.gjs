import Component from "@glimmer/component";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { resizeAllGridItems } from "../../lib/gridupdate";

export default class LayoutRefresh extends Component {
  @service topicListPreviews;

  attachResizeObserver = modifier((element) => {
    const topicList = element.closest(".topic-list");

    if (!topicList) {
      // eslint-disable-next-line no-console
      console.error(
        "topic-list-previews resize-observer must be inside a topic-list"
      );
      return;
    }

    const  listAreaSizeObserver = new ResizeObserver(resizeAllGridItems)

    listAreaSizeObserver.observe(topicList);

    return () => {
      listAreaSizeObserver.disconnect();
    };
  });

  <template>
    {{#if this.topicListPreviews.displayTiles}}
      {{! template-lint-disable no-forbidden-elements }}
      <div {{this.attachResizeObserver}}>

      </div>
    {{/if}}
  </template>
}