import Component from "@glimmer/component";
import avatar from "discourse/helpers/avatar";

export default class PreviewsUsers extends Component {
  get abbrieviatedPosters() {
    let abbreviatedPosters = [];
    if (this.args.topic.posters.length < 6) {
      abbreviatedPosters = this.args.topic.posters;
    } else {
      this.args.topic.posters[0].count = false;
      abbreviatedPosters.push(this.args.topic.posters[0]);
      this.args.topic.posters[1].count = false;
      abbreviatedPosters.push(this.args.topic.posters[1]);
      let count = { count: this.args.topic.posters.length - 4 };
      abbreviatedPosters.push(count);
      this.args.topic.posters[this.args.topic.posters.length - 2].count = false;
      abbreviatedPosters.push(
        this.args.topic.posters[this.args.topic.posters.length - 2]
      );
      this.args.topic.posters[this.args.topic.posters.length - 1].count = false;
      abbreviatedPosters.push(
        this.args.topic.posters[this.args.topic.posters.length - 1]
      );
    }
    return abbreviatedPosters;
  }

  <template>
    <div class="topic-users">
      <div class="inline">
        {{#each this.abbrieviatedPosters as |poster|}}
          {{#if poster.count}}
            ({{poster.count}})
          {{else}}
            <a
              href={{poster.user.path}}
              data-user-card={{poster.user.username}}
              class={{poster.extras}}
            >
              {{avatar
                poster
                avatarTemplatePath="user.avatar_template"
                usernamePath="user.username"
                imageSize="small"
              }}
            </a>
          {{/if}}
        {{/each}}
      </div>
    </div>
  </template>
}
