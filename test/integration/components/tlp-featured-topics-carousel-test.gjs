import Service from "@ember/service";
import {
  click,
  find,
  render,
  triggerEvent,
  triggerKeyEvent,
} from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import { stubPointerCapture } from "discourse/tests/helpers/ui-kit/pointer-gesture-helper";
import TlpFeaturedTopicsCarousel from "../../../discourse/components/tlp-featured-topics-carousel";

const TOPICS = [
  { id: 1, title: "One" },
  { id: 2, title: "Two" },
  { id: 3, title: "Three" },
  { id: 4, title: "Four" },
  { id: 5, title: "Five" },
];
const SEVEN_TOPICS = [
  ...TOPICS,
  { id: 6, title: "Six" },
  { id: 7, title: "Seven" },
];
const EIGHT_TOPICS = [...SEVEN_TOPICS, { id: 8, title: "Eight" }];

class A11yStub extends Service {
  announce() {}
}

class MobileCapabilitiesStub extends Service {
  isIOS = false;
  viewport = { sm: false };
}

class IOSMobileCapabilitiesStub extends MobileCapabilitiesStub {
  isIOS = true;
}

module("Integration | Component | TlpFeaturedTopicsCarousel", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    this.owner.unregister("service:a11y");
    this.owner.register("service:a11y", A11yStub);
    this.topics = TOPICS;
  });

  test("desktop navigation moves a spaced three-image row through the topics", async function (assert) {
    await render(
      <template>
        <TlpFeaturedTopicsCarousel @topics={{this.topics}}>
          <:default as |topic|>
            <span class="test-topic">{{topic.title}}</span>
          </:default>

          <:positionTrailing>
            <span class="featured-source">Featured</span>
          </:positionTrailing>
        </TlpFeaturedTopicsCarousel>
      </template>
    );

    assert
      .dom(".tlp-featured-topics__slide")
      .exists({ count: 5 }, "all topics are rendered in the track");
    assert
      .dom(".tlp-featured-topics__position-dot")
      .exists({ count: 3 }, "desktop retains the compact position indicator");
    assert
      .dom(".tlp-featured-topics__position-trailing .featured-source")
      .hasText("Featured", "the position row exposes trailing content");
    assert
      .dom(".tlp-featured-topics__track")
      .hasAttribute(
        "style",
        /--tlp-desktop-carousel-width: calc\(33\.333.*% - 0\.5em\); --tlp-carousel-gap: 0\.75em;/,
        "three complete images are sized with equal space between them"
      );
    assert
      .dom(".tlp-featured-topics__position .sr-only")
      .hasText(
        "1–3 of 5 featured topics",
        "the initial visible range is exposed"
      );
    assert
      .dom(".tlp-featured-topics__navigation.--previous")
      .isDisabled("previous is disabled at the beginning");
    assert
      .dom(".tlp-featured-topics__position-dot:nth-child(2)")
      .hasClass("is-active", "the beginning dot is active");

    await click(".tlp-featured-topics__navigation.--next");

    assert
      .dom(".tlp-featured-topics__position .sr-only")
      .hasText("2–4 of 5 featured topics", "the window advances by one topic");
    assert
      .dom(".tlp-featured-topics__position-dot:nth-child(3)")
      .hasClass("is-active", "the middle dot is active");

    await click(".tlp-featured-topics__navigation.--next");

    assert
      .dom(".tlp-featured-topics__position .sr-only")
      .hasText("3–5 of 5 featured topics", "the final window is exposed");
    assert
      .dom(".tlp-featured-topics__navigation.--next")
      .isDisabled("next is disabled at the end");
    assert
      .dom(".tlp-featured-topics__position-dot:nth-child(4)")
      .hasClass("is-active", "the end dot is active");
  });

  test("the carousel supports arrow, Home, and End keys", async function (assert) {
    await render(
      <template>
        <TlpFeaturedTopicsCarousel @topics={{this.topics}} as |topic|>
          <span>{{topic.title}}</span>
        </TlpFeaturedTopicsCarousel>
      </template>
    );

    await triggerKeyEvent(".tlp-featured-topics__viewport", "keydown", "End");
    assert
      .dom(".tlp-featured-topics__position .sr-only")
      .hasText("3–5 of 5 featured topics", "End moves to the final window");

    await triggerKeyEvent(
      ".tlp-featured-topics__viewport",
      "keydown",
      "ArrowLeft"
    );
    assert
      .dom(".tlp-featured-topics__position .sr-only")
      .hasText("2–4 of 5 featured topics", "ArrowLeft moves backward");

    await triggerKeyEvent(".tlp-featured-topics__viewport", "keydown", "Home");
    assert
      .dom(".tlp-featured-topics__position .sr-only")
      .hasText("1–3 of 5 featured topics", "Home returns to the beginning");
  });

  test("mobile drag advances a single-image window", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", MobileCapabilitiesStub);
    this.topics = SEVEN_TOPICS;

    await render(
      <template>
        <TlpFeaturedTopicsCarousel @topics={{this.topics}} as |topic|>
          <span>{{topic.title}}</span>
        </TlpFeaturedTopicsCarousel>
      </template>
    );

    assert
      .dom(".tlp-featured-topics__position-dot")
      .exists(
        { count: 7 },
        "a mobile list of seven topics renders one dot per topic"
      );
    assert
      .dom(".tlp-featured-topics__position-dot.is-active")
      .exists({ count: 1 }, "only the first topic dot is initially active");

    const viewport = find(".tlp-featured-topics__viewport");
    Object.defineProperty(viewport, "clientWidth", { value: 300 });
    stubPointerCapture(viewport);

    await triggerEvent(viewport, "pointerdown", {
      button: 0,
      pointerId: 1,
      clientX: 250,
    });
    await triggerEvent(viewport, "pointermove", {
      pointerId: 1,
      clientX: 50,
    });
    await triggerEvent(viewport, "pointerup", {
      pointerId: 1,
      clientX: 50,
    });

    assert
      .dom(".tlp-featured-topics__position .sr-only")
      .hasText("2–2 of 7 featured topics", "the drag advances one image");
    assert
      .dom(".tlp-featured-topics__position-dot:nth-child(3)")
      .hasClass("is-active", "the second topic dot is active");
    assert
      .dom(".tlp-featured-topics__position-dot.is-active")
      .exists({ count: 1 }, "only the current topic dot is active");
  });

  for (const { platform, capabilities, expectedPosition } of [
    {
      platform: "iOS",
      capabilities: IOSMobileCapabilitiesStub,
      expectedPosition: "2–2 of 5 featured topics",
    },
    {
      platform: "Android",
      capabilities: MobileCapabilitiesStub,
      expectedPosition: "1–1 of 5 featured topics",
    },
  ]) {
    test(`${platform} handles a cancelled mobile drag`, async function (assert) {
      this.owner.unregister("service:capabilities");
      this.owner.register("service:capabilities", capabilities);

      await render(
        <template>
          <TlpFeaturedTopicsCarousel @topics={{this.topics}} as |topic|>
            <span>{{topic.title}}</span>
          </TlpFeaturedTopicsCarousel>
        </template>
      );

      const viewport = find(".tlp-featured-topics__viewport");
      Object.defineProperty(viewport, "clientWidth", { value: 300 });
      stubPointerCapture(viewport);

      await triggerEvent(viewport, "pointerdown", {
        button: 0,
        pointerId: 1,
        clientX: 280,
      });
      await triggerEvent(viewport, "pointermove", {
        pointerId: 1,
        clientX: 20,
      });
      await triggerEvent(viewport, "pointercancel", {
        pointerId: 1,
        clientX: 20,
      });

      assert
        .dom(".tlp-featured-topics__position .sr-only")
        .hasText(
          expectedPosition,
          "iOS commits the swipe while Android retains cancellation behaviour"
        );
    });
  }

  test("mobile lists longer than seven topics use the compact indicator", async function (assert) {
    this.owner.unregister("service:capabilities");
    this.owner.register("service:capabilities", MobileCapabilitiesStub);
    this.topics = EIGHT_TOPICS;

    await render(
      <template>
        <TlpFeaturedTopicsCarousel @topics={{this.topics}} as |topic|>
          <span>{{topic.title}}</span>
        </TlpFeaturedTopicsCarousel>
      </template>
    );

    assert
      .dom(".tlp-featured-topics__position-dot")
      .exists(
        { count: 3 },
        "a mobile list of eight topics retains the compact indicator"
      );
    assert
      .dom(".tlp-featured-topics__position-dot:nth-child(2)")
      .hasClass("is-active", "the beginning dot is active");

    await triggerKeyEvent(".tlp-featured-topics__viewport", "keydown", "End");

    assert
      .dom(".tlp-featured-topics__position-dot:nth-child(4)")
      .hasClass("is-active", "the end dot becomes active");
  });
});
