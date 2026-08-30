import { clearRender, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import pretender, { response } from "discourse/tests/helpers/create-pretender";
import TlpFeaturedTopicsPlacement from "../../../discourse/components/tlp-featured-topics-placement";

module(
  "Integration | Component | TlpFeaturedTopicsPlacement",
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      this.originalPlacement = settings.topic_list_featured_images_placement;
      this.originalEnabled = settings.topic_list_featured_images;
      this.originalCategoryEnabled =
        settings.topic_list_featured_images_category;
      this.originalSource = settings.topic_list_featured_images_tag;

      settings.topic_list_featured_images = true;
      settings.topic_list_featured_images_category = true;
      settings.topic_list_featured_images_tag = "featured";

      pretender.get("/tag/featured.json", () =>
        response({ users: [], primary_groups: [], topic_list: { topics: [] } })
      );
    });

    hooks.afterEach(function () {
      settings.topic_list_featured_images_placement = this.originalPlacement;
      settings.topic_list_featured_images = this.originalEnabled;
      settings.topic_list_featured_images_category =
        this.originalCategoryEnabled;
      settings.topic_list_featured_images_tag = this.originalSource;
    });

    test("renders featured topics in only the configured outlet", async function (assert) {
      settings.topic_list_featured_images_placement = "Above topic list";

      await render(
        <template>
          <div class="test-above-topic-list">
            <TlpFeaturedTopicsPlacement @placement="Above topic list" />
          </div>
          <div class="test-above-navigation">
            <TlpFeaturedTopicsPlacement
              @placement="Above navigation controls"
            />
          </div>
        </template>
      );

      assert.dom(".test-above-topic-list .tlp-featured-topics").exists();
      assert.dom(".test-above-navigation .tlp-featured-topics").doesNotExist();

      await clearRender();
      settings.topic_list_featured_images_placement =
        "Above navigation controls";

      await render(
        <template>
          <div class="test-above-topic-list">
            <TlpFeaturedTopicsPlacement @placement="Above topic list" />
          </div>
          <div class="test-above-navigation">
            <TlpFeaturedTopicsPlacement
              @placement="Above navigation controls"
            />
          </div>
        </template>
      );

      assert.dom(".test-above-topic-list .tlp-featured-topics").doesNotExist();
      assert.dom(".test-above-navigation .tlp-featured-topics").exists();
    });

    test("does not render or load on a disabled route", async function (assert) {
      settings.topic_list_featured_images = false;

      await render(
        <template>
          <TlpFeaturedTopicsPlacement @placement="Above topic list" />
        </template>
      );

      assert
        .dom(".tlp-featured-topics")
        .doesNotExist("the loading component is not instantiated");
    });

    test("does not render or load without a source", async function (assert) {
      settings.topic_list_featured_images_tag = "";

      await render(
        <template>
          <TlpFeaturedTopicsPlacement @placement="Above topic list" />
        </template>
      );

      assert
        .dom(".tlp-featured-topics")
        .doesNotExist("the loading component is not instantiated");
    });
  }
);
