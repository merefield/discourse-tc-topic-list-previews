import ShareTopicModal from "discourse/components/modal/share-topic";
import Component from "@glimmer/component";
import { getOwner } from "@ember/application";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import concatClass from "discourse/helpers/concat-class";
import DButton from "discourse/components/d-button";
import icon from "discourse/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";

export default class PreviewsActionsComponent extends Component {
  @service currentUser;
  @service modal;
  topicId = this.args.topic.id;
  postId = this.args.topic_post_id;
  @tracked likeCount = this.args.topic.like_count;
  @tracked hasLiked = this.args.topic.topic_post_liked;
  @tracked bookmarked = this.args.topic.topic_post_bookmarked;

  @action
  shareTopic() {
    this.modal.show(ShareTopicModal, {
      model: {
        category: this.args.topic.category,
        topic: this.args.topic,
      }
    })
  };

  @action
  toggleLike() {
    if (this.hasLiked) {
      ajax("/post_actions/" + this.postId, {
      type: "DELETE",
      data: {
        post_action_type_id: 2,
      },
    }).then(() => {
      this.hasLiked = false;
      this.likeCount--;
      }).catch(function (error) {
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
    }).then(() => {
      this.hasLiked = true;
      this.likeCount++;
    }).catch(function (error) {
      popupAjaxError(error);
    });
    }
  };

  @action
  toggledBookmark() {
    if (!this.bookmarked) {
      const data = {
        reminder_type: null,
        reminder_at: null,
        name: null,
        bookmarkable_id: this.postId,
        bookmarkable_type: 'Post',
      };
      ajax("/bookmarks", {
        type: "POST",
        data,
      }).then(() => {
        this.bookmarked = true;
      }).catch((error) => {
        popupAjaxError(error);
      });
    } else {
      ajax(`/t/${this.topicId}/remove_bookmarks`, {
        type: "PUT",
      }).then(() => {
        this.bookmarked = false;
        }).catch((error) => {
          popupAjaxError(error);
        });
    }
  };

// @action
// var removeLike = function (postId) {
//   ajax("/post_actions/" + postId, {
//     type: "DELETE",
//     data: {
//       post_action_type_id: 2,
//     },
//   }).catch(function (error) {
//     popupAjaxError(error);
//   });
// };

    // @discourseComputed("likeCount")
    // topicActions(likeCount) {
    //   let actions = [];
    //   if (
    //     likeCount ||
    //     this.get("topic.topic_post_can_like") ||
    //     !this.get("currentUser") ||
    //     settings.topic_list_show_like_on_current_users_posts
    //   ) {
    //     actions.push(this._likeButton());
    //   }
    //   actions.push(this._shareButton());
    //   if (this.get("canBookmark")) {
    //     actions.push(this._bookmarkButton());
    //     scheduleOnce("afterRender", this, () => {
    //       if (this.isDestroying) return;
    //       let bookmarkStatusElement = this.element.querySelector(
    //         ".topic-statuses .op-bookmark"
    //       );
    //       if (bookmarkStatusElement) {
    //         bookmarkStatusElement.style.display = "none";
    //       }
    //     });
    //   }
    //   return actions;
    // },

//     var buttonHTML = function (action, topic) {
//   action = action || {};

//   var html = "<button class='list-button " + action.class + "'";
//   if (action.title) {
//     html += 'title="' + I18n.t(action.title) + '"';
//   }
//   if (action.topic_id) {
//     html += ` data-topic_id=${action.topic_id}`;
//   }
//   if (action.topic_post_id) {
//     html += ` data-topic_post_id=${action.topic_post_id}`;
//   }
//   if (action.disabled) {
//     html += " disabled=true";
//   }
//   if (action.type == "like" && action.like_count > 0) {
//     html += `><span class="like-count">${action.like_count}</span>${iconHTML(
//       action.icon
//     )}`;
//   } else if (action.type == "like" && action.like_count == 0) {
//     html += `><span class="like-count"></span>${iconHTML(action.icon)}`;
//   } else {
//     html += `>${iconHTML(action.icon)}`;
//   }
//   html += "</button>";
//   return html;
// };

        // _shareButton() {
        //   let classes = "topic-share";
        //   return {
        //     type: "share",
        //     class: classes,
        //     title: "js.topic.share.help",
        //     icon: "link",
        //     topic: this.topic,
        //   };
        // },

        // _likeButton() {
        //   let classes = "topic-like";
        //   let disabled = this.get("topic.topic_post_is_current_users");

        //   if (this.get("hasLiked")) {
        //     classes += " has-like";
        //     disabled = disabled ? true : !this.get("canUnlike");
        //   }
        //   return {
        //     type: "like",
        //     class: classes,
        //     title: "post.controls.like",
        //     icon: "heart",
        //     disabled: disabled,
        //     topic_id: this.topic.id,
        //     topic_post_id: this.topic.topic_post_id,
        //     like_count: this.likeCount,
        //     has_liked: this.hasLiked,
        //   };
        // },

        // _bookmarkButton() {
        //   var classes = "topic-bookmark",
        //     title = "bookmarks.not_bookmarked";
        //   if (this.get("topic.topic_post_bookmarked")) {
        //     classes += " bookmarked";
        //     title = "bookmarks.remove";
        //   }
        //   return {
        //     type: "bookmark",
        //     class: classes,
        //     title: title,
        //     icon: "bookmark",
        //     topic_id: this.topic.id,
        //     topic_post_id: this.topic.topic_post_id,
        //   };
        // },


  get showLikeButton() {
    return (
      this.args.topic.like_count ||
      this.args.topic.topic_post_can_like ||
      !this.currentUser ||
      settings.topic_list_show_like_on_current_users_posts
    ) 
  }

  get disabledLikeButton() {
    return (
      this.args.topic.topic_post_is_current_users ||
      (this.args.topic.topic_post_liked && !this.args.topic.topic_post_can_unlike)
    );
  }

  get hasLike(){
    return this.args.topic.hasLiked ? "has-like" : "";
  }

  get likeDisabled(){
    let disabled = this.args.topic.topic_post_is_current_users;
    if (this.args.topic.hasLiked) {
      disabled = disabled ? true : !this.args.topic.canUnlike;
    }
    return disabled;
  }

  get showBookmarkButton() {
    return this.currentUser;
  }

  get bookmarkClass() {
    return this.bookmarked ? "bookmarked" : "";
  }

  get bookmarkTitle() {
    const suffix = this.bookmarked ? "remove" : "not_bookmarked"; 
    return `bookmarks.${suffix}`
  }


  <template>
    <div class="topic-actions">
      <div class="inline">
        {{#if this.showLikeButton}}
          <DButton
            @action={{this.toggleLike}}
            class={{concatClass "list-button btn-transparent topic-like" this.hasLike}}
            title={{i18n "post.controls.like"}}
            disabled={{this.likeDisabled}}
            data-topic_id={{@topic.id}}
            data-topic_post_id={{@topic_post_id}}
          >
            {{#if @topic.like_count}}
              <span class="like-count">{{@topic.like_count}}</span>
            {{/if}}
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
            class={{concatClass "list-button btn-transparent topic-bookmark" this.bookmarkClass}}
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