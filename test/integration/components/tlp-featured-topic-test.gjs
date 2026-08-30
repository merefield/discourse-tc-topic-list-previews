import Service from "@ember/service";
import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import TlpFeaturedTopic from "../../../discourse/components/tlp-featured-topic";

class DesktopCapabilitiesStub extends Service {
  viewport = { sm: true };
}

class MobileCapabilitiesStub extends Service {
  viewport = { sm: false };
}

const TOPIC = {
  id: 1,
  title: "Featured topic",
  excerpt: "Excerpt text for the featured topic",
  posters: [
    {
      user: {
        avatar_template: "/letter_avatar_proxy/v4/letter/a/13edae/{size}.png",
        username: "alice",
      },
    },
  ],
  tags: [],
  thumbnails: [{ url: "/images/avatar.png" }],
  url: "/t/featured-topic/1",
};

module("Integration | Component | TlpFeaturedTopic", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.currentUser.set("custom_fields", {});
    this.originalSettings = {
      desktopAuthor: settings.topic_list_featured_author_desktop,
      desktopDetails: settings.topic_list_featured_details_desktop,
      desktopExcerpt: settings.topic_list_featured_excerpt_desktop,
      mobileAuthor: settings.topic_list_featured_author_mobile,
      mobileDetails: settings.topic_list_featured_details_mobile,
      mobileExcerpt: settings.topic_list_featured_excerpt_mobile,
    };
    this.topic = TOPIC;
  });

  hooks.afterEach(function () {
    settings.topic_list_featured_author_desktop =
      this.originalSettings.desktopAuthor;
    settings.topic_list_featured_details_desktop =
      this.originalSettings.desktopDetails;
    settings.topic_list_featured_excerpt_desktop =
      this.originalSettings.desktopExcerpt;
    settings.topic_list_featured_author_mobile =
      this.originalSettings.mobileAuthor;
    settings.topic_list_featured_details_mobile =
      this.originalSettings.mobileDetails;
    settings.topic_list_featured_excerpt_mobile =
      this.originalSettings.mobileExcerpt;
  });

  test("desktop under mode renders title and excerpt below the image", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", DesktopCapabilitiesStub);
    settings.topic_list_featured_author_desktop = true;
    settings.topic_list_featured_details_desktop = "Under";
    settings.topic_list_featured_excerpt_desktop = 7;
    settings.topic_list_featured_excerpt_mobile = 0;

    await render(
      <template><TlpFeaturedTopic @topic={{this.topic}} /></template>
    );

    assert
      .dom(".featured-details")
      .hasClass("--under", "the under-image presentation is selected");
    assert
      .dom(".featured-details__image + .content")
      .exists("the details section follows the image");
    assert
      .dom(".content .title")
      .hasText("Featured topic", "the title is shown");
    assert
      .dom(".content .excerpt")
      .hasText("Excerpt", "the desktop excerpt length is applied");
    assert.dom(".content .user").doesNotExist("the username is omitted");
    assert
      .dom(".featured-details__heading > a.featured-details__author")
      .hasAttribute(
        "data-user-card",
        "alice",
        "the avatar opens the desktop user card"
      );
    assert
      .dom(".featured-details__heading > a.featured-details__author")
      .hasAttribute("href", "/u/alice", "the avatar links to the user profile");
  });

  test("desktop over-on-hover mode retains attribution without forcing visibility", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", DesktopCapabilitiesStub);
    settings.topic_list_featured_author_desktop = true;
    settings.topic_list_featured_details_desktop = "Over on hover";
    settings.topic_list_featured_excerpt_desktop = 0;

    await render(
      <template><TlpFeaturedTopic @topic={{this.topic}} /></template>
    );

    assert
      .dom(".featured-details")
      .hasClass("--over", "the overlay presentation is selected");
    assert
      .dom(".featured-details")
      .doesNotHaveClass(
        "is-always-visible",
        "the overlay is revealed only by hover"
      );
    assert.dom(".content .excerpt").doesNotExist("the excerpt is disabled");
    assert.dom(".content .user").hasText(/alice/, "attribution is retained");
    assert
      .dom(".content .user > a.featured-details__author")
      .hasAttribute(
        "data-user-card",
        "alice",
        "the overlay avatar opens the desktop user card"
      );
  });

  test("desktop always-over mode forces the overlay visible", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", DesktopCapabilitiesStub);
    settings.topic_list_featured_details_desktop = "Always over";

    await render(
      <template><TlpFeaturedTopic @topic={{this.topic}} /></template>
    );

    assert
      .dom(".featured-details.--over")
      .hasClass("is-always-visible", "the desktop overlay is always visible");
  });

  test("mobile over mode uses the mobile excerpt and retains attribution", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", MobileCapabilitiesStub);
    settings.topic_list_featured_author_mobile = true;
    settings.topic_list_featured_details_mobile = "Over";
    settings.topic_list_featured_excerpt_desktop = 0;
    settings.topic_list_featured_excerpt_mobile = 7;

    await render(
      <template><TlpFeaturedTopic @topic={{this.topic}} /></template>
    );

    assert
      .dom(".featured-details.--over")
      .hasClass("is-always-visible", "the mobile overlay is visible");
    assert
      .dom(".content .excerpt")
      .hasText("Excerpt", "the mobile excerpt length is applied");
    assert.dom(".content .user").hasText(/alice/, "attribution is retained");
    assert
      .dom(".content .user > span.featured-details__author")
      .doesNotHaveAttribute(
        "data-user-card",
        "the mobile avatar remains non-interactive"
      );
  });

  test("mobile under mode shows only the avatar beside the title", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", MobileCapabilitiesStub);
    settings.topic_list_featured_author_mobile = true;
    settings.topic_list_featured_details_mobile = "Under";
    settings.topic_list_featured_excerpt_mobile = 0;

    await render(
      <template><TlpFeaturedTopic @topic={{this.topic}} /></template>
    );

    assert
      .dom(".featured-details")
      .hasClass("--under", "the mobile details follow the image");
    assert
      .dom(".content .title")
      .hasText("Featured topic", "the title is shown");
    assert.dom(".content .excerpt").doesNotExist("the excerpt is disabled");
    assert.dom(".content .user").doesNotExist("the username is omitted");
    assert
      .dom(".featured-details__heading > span.featured-details__author")
      .exists("only the avatar is shown beside the title");
  });

  test("desktop author setting can hide the author", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", DesktopCapabilitiesStub);
    settings.topic_list_featured_author_desktop = false;
    settings.topic_list_featured_details_desktop = "Always over";

    await render(
      <template><TlpFeaturedTopic @topic={{this.topic}} /></template>
    );

    assert
      .dom(".featured-details__author")
      .doesNotExist("the desktop author is hidden");
    assert.dom(".content .user").doesNotExist("the username is hidden");
  });

  test("mobile author setting can hide the author", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", MobileCapabilitiesStub);
    settings.topic_list_featured_author_mobile = false;
    settings.topic_list_featured_details_mobile = "Under";

    await render(
      <template><TlpFeaturedTopic @topic={{this.topic}} /></template>
    );

    assert
      .dom(".featured-details__author")
      .doesNotExist("the mobile author is hidden");
    assert.dom(".content .user").doesNotExist("the username is hidden");
  });
});
