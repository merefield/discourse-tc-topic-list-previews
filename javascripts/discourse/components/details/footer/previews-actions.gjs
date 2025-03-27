import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import ShareTopicModal from "discourse/components/modal/share-topic";
import concatClass from "discourse/helpers/concat-class";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class PreviewsActionsComponent extends Component {
  @service siteSettings;
  @service currentUser;
  @service modal;

  @tracked
  canUnlike =
    this.args.topic.topic_post_can_unlike || !this.args.topic.topic_post_liked;
  @tracked likeCount = this.args.topic.like_count;
  @tracked hasLiked = this.args.topic.topic_post_liked;
  @tracked bookmarked = this.args.topic.topic_post_bookmarked;
  topicId = this.args.topic.id;
  postId = this.args.topic.topic_post_id;

  @action
  shareTopic() {
    this.modal.show(ShareTopicModal, {
      model: {
        category: this.args.topic.category,
        topic: this.args.topic,
      },
    });
  }

  @action
  toggleLike() {
    if (this.hasLiked) {
      ajax("/post_actions/" + this.postId, {
        type: "DELETE",
        data: {
          post_action_type_id: 2,
        },
      })
        .then(() => {
          this.hasLiked = false;
          this.likeCount--;
        })
        .catch(function (error) {
          popupAjaxError(error);
        });
    } else {
      ajax("/post_actions", {
        type: "POST",
        data: {
          id: this.postId,
          post_action_type_id: 2,
        },
        returnXHR: true,
      })
        .then(() => {
          this.hasLiked = true;
          this.likeCount++;
        })
        .catch(function (error) {
          popupAjaxError(error);
        });
    }
  }

  @action
  toggleBookmark() {
    if (!this.bookmarked) {
      const data = {
        reminder_type: null,
        reminder_at: null,
        name: null,
        bookmarkable_id: this.postId,
        bookmarkable_type: "Post",
      };
      ajax("/bookmarks", {
        type: "POST",
        data,
      })
        .then(() => {
          this.bookmarked = true;
        })
        .catch((error) => {
          popupAjaxError(error);
        });
    } else {
      ajax(`/t/${this.topicId}/remove_bookmarks`, {
        type: "PUT",
      })
        .then(() => {
          this.bookmarked = false;
        })
        .catch((error) => {
          popupAjaxError(error);
        });
    }
  }

  get sidecarInstalled() {
    return this.siteSettings.topic_list_previews_enabled;
  }

  get showLikeButton() {
    if (!this.sidecarInstalled) {
      return false;
    }

    return (
      this.args.topic.like_count ||
      this.args.topic.topic_post_can_like ||
      !this.currentUser ||
      settings.topic_list_show_like_on_current_users_posts
    );
  }

  get disabledLikeButton() {
    return (
      this.args.topic.topic_post_is_current_users ||
      (this.args.topic.topic_post_liked &&
        !this.args.topic.topic_post_can_unlike)
    );
  }

  get hasLike() {
    return this.hasLiked ? "has-liked" : "";
  }

  get likeDisabled() {
    let disabled = this.args.topic.topic_post_is_current_users;
    if (this.hasLiked) {
      disabled = disabled ? true : !this.canUnlike;
    }
    return disabled;
  }

  get showBookmarkButton() {
    if (!this.sidecarInstalled) {
      return false;
    }

    return this.currentUser;
  }

  get bookmarkClass() {
    return this.bookmarked ? "bookmarked" : "";
  }

  get bookmarkTitle() {
    const suffix = this.bookmarked ? "remove" : "not_bookmarked";
    return `bookmarks.${suffix}`;
  }

  <template>
    <div class="topic-actions">
      <div class="inline">
        {{#if this.showLikeButton}}
          {{#if this.likeCount}}
            <span class="like-count">{{this.likeCount}}</span>
          {{/if}}
          <DButton
            @action={{this.toggleLike}}
            class={{concatClass
              "list-button btn-transparent topic-like"
              this.hasLike
            }}
            title={{i18n "post.controls.like"}}
            disabled={{this.likeDisabled}}
            data-topic_id={{@topic.id}}
            data-topic_post_id={{@topic_post_id}}
          >
            {{icon "heart"}}
          </DButton>
        {{/if}}
        <DButton
          @action={{this.shareTopic}}
          class="list-button btn-transparent topic-share"
          title={{i18n "js.topic.share.help"}}
          data-topic_id={{@topic.id}}
          data-topic_post_id={{@topic_post_id}}
          @icon="link"
        />
        {{#if this.showBookmarkButton}}
          <DButton
            @action={{this.toggleBookmark}}
            class={{concatClass
              "list-button btn-transparent topic-bookmark"
              this.bookmarkClass
            }}
            title={{i18n this.bookmarkTitle}}
            data-topic_id={{@topic.id}}
            data-topic_post_id={{@topic_post_id}}
            @icon="bookmark"
          />
        {{/if}}
      </div>
    </div>
  </template>
}
