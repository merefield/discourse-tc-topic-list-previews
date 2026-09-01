import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { registerDestructor } from "@ember/destroyable";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import DButton from "discourse/ui-kit/d-button";
import dOnResize from "discourse/ui-kit/modifiers/d-on-resize";
import dPointerDrag from "discourse/ui-kit/modifiers/d-pointer-drag";
import { i18n } from "discourse-i18n";
import { carouselCountForWidth } from "../lib/featured-carousel-layout";

const DRAG_RESISTANCE = 0.28;
const DESKTOP_GAP_EM = 0.75;
const FLICK_PROJECTION_SECONDS = 0.18;
const MIN_FLICK_VELOCITY = 600;
const SPRING_DAMPING = 24;
const SPRING_STIFFNESS = 210;

export default class TlpFeaturedTopicsCarouselComponent extends Component {
  @service a11y;
  @service capabilities;

  @tracked currentPosition = 0;
  @tracked dragOffset = 0;
  @tracked isSettling = false;
  @tracked responsiveDesktopCount;

  #animationFrame;
  #dragStartPosition = 0;
  #lastPointerTime = 0;
  #lastPointerX = 0;
  #pointerVelocity = 0;
  #suppressClickUntil = 0;
  #viewportWidth = 1;

  constructor() {
    super(...arguments);
    registerDestructor(this, () => this.#cancelSpring());
  }

  get topics() {
    return this.args.topics ?? [];
  }

  get desktopCarouselCount() {
    const configured = Number(
      settings.topic_list_featured_images_carousel_count
    );
    return Math.min(4, Math.max(1, configured || 3));
  }

  get visibleCount() {
    return this.capabilities.viewport.sm ? this.desktopVisibleCount : 1;
  }

  get desktopVisibleCount() {
    return Math.min(
      this.desktopCarouselCount,
      this.responsiveDesktopCount ?? this.desktopCarouselCount,
      Math.max(1, this.topics.length)
    );
  }

  get minimumDesktopSlideWidth() {
    const featuredHeight = Number(settings.topic_list_featured_height) || 250;
    return Math.min(320, Math.max(180, featuredHeight));
  }

  get maxPosition() {
    return Math.max(0, this.topics.length - this.visibleCount);
  }

  get position() {
    return Math.min(this.currentPosition, this.maxPosition);
  }

  get atStart() {
    return this.position === 0;
  }

  get atEnd() {
    return this.position === this.maxPosition;
  }

  get inMiddle() {
    return !this.atStart && !this.atEnd;
  }

  get isRtl() {
    return document.documentElement.dir === "rtl";
  }

  get previousIcon() {
    return this.isRtl ? "chevron-right" : "chevron-left";
  }

  get nextIcon() {
    return this.isRtl ? "chevron-left" : "chevron-right";
  }

  get positionLabel() {
    const start = this.topics.length ? this.position + 1 : 0;
    const end = Math.min(this.position + this.visibleCount, this.topics.length);

    return i18n(themePrefix("tlp.featured_topics.position"), {
      start,
      end,
      total: this.topics.length,
    });
  }

  get positionDots() {
    if (!this.capabilities.viewport.sm && this.topics.length <= 7) {
      return this.topics.map((_topic, index) => ({
        id: `topic-${index}`,
        isActive: index === this.position,
      }));
    }

    return [
      { id: "start", isActive: this.atStart },
      { id: "middle", isActive: this.inMiddle },
      { id: "end", isActive: this.atEnd },
    ];
  }

  get trackStyle() {
    const desktopOffset = (this.position * 100) / this.desktopVisibleCount;
    const desktopGapOffset =
      (this.position * DESKTOP_GAP_EM) / this.desktopVisibleCount;
    const desktopWidth = 100 / this.desktopVisibleCount;
    const desktopWidthGap =
      (DESKTOP_GAP_EM * (this.desktopVisibleCount - 1)) /
      this.desktopVisibleCount;
    const mobileOffset = this.position * 100;

    return trustHTML(
      `--tlp-desktop-carousel-width: calc(${desktopWidth}% - ${desktopWidthGap}em); ` +
        `--tlp-carousel-gap: ${DESKTOP_GAP_EM}em; ` +
        `--tlp-desktop-offset: calc(-${desktopOffset}% - ${desktopGapOffset}em); ` +
        `--tlp-desktop-offset-rtl: calc(${desktopOffset}% + ${desktopGapOffset}em); ` +
        `--tlp-mobile-offset: -${mobileOffset}%; ` +
        `--tlp-mobile-offset-rtl: ${mobileOffset}%; ` +
        `--tlp-drag-offset: ${this.dragOffset}px;`
    );
  }

  announcePosition() {
    this.a11y.announce(this.positionLabel);
  }

  moveTo(position, announce = true) {
    const nextPosition = Math.min(this.maxPosition, Math.max(0, position));
    if (nextPosition === this.position) {
      return;
    }

    this.#cancelSpring();
    this.dragOffset = 0;
    this.isSettling = false;
    this.currentPosition = nextPosition;

    if (announce) {
      this.announcePosition();
    }
  }

  @action
  previous() {
    this.moveTo(this.position - 1);
  }

  @action
  next() {
    this.moveTo(this.position + 1);
  }

  @action
  onKeydown(event) {
    let nextPosition;

    switch (event.key) {
      case "ArrowLeft":
        nextPosition = this.position + (this.isRtl ? 1 : -1);
        break;
      case "ArrowRight":
        nextPosition = this.position + (this.isRtl ? -1 : 1);
        break;
      case "Home":
        nextPosition = 0;
        break;
      case "End":
        nextPosition = this.maxPosition;
        break;
      default:
        return;
    }

    event.preventDefault();
    this.moveTo(nextPosition);
  }

  @action
  onResize([entry]) {
    if (!this.capabilities.viewport.sm) {
      return;
    }

    const width = entry.contentRect.width;
    const fontSize = parseFloat(getComputedStyle(entry.target).fontSize) || 16;
    const previousPosition = this.position;

    this.responsiveDesktopCount = carouselCountForWidth({
      gap: DESKTOP_GAP_EM * fontSize,
      maximum: this.desktopCarouselCount,
      minimumWidth: this.minimumDesktopSlideWidth,
      width,
    });
    this.currentPosition = Math.min(previousPosition, this.maxPosition);
  }

  @action
  onDragStart(event) {
    if (this.capabilities.viewport.sm || this.maxPosition === 0) {
      return false;
    }

    this.#cancelSpring();
    this.currentPosition = this.position;
    this.dragOffset = 0;
    this.isSettling = false;
    this.#dragStartPosition = this.position;
    this.#lastPointerX = event.clientX;
    this.#lastPointerTime = event.timeStamp;
    this.#pointerVelocity = 0;
    this.#viewportWidth = Math.max(1, event.currentTarget.clientWidth);
  }

  @action
  onDrag(event, info) {
    let logicalDelta = info.delta.x * (this.isRtl ? 1 : -1);

    if (
      (this.#dragStartPosition === 0 && logicalDelta < 0) ||
      (this.#dragStartPosition === this.maxPosition && logicalDelta > 0)
    ) {
      logicalDelta *= DRAG_RESISTANCE;
    }

    this.dragOffset = logicalDelta * (this.isRtl ? 1 : -1);

    const elapsed = event.timeStamp - this.#lastPointerTime;
    if (elapsed > 0) {
      this.#pointerVelocity =
        ((event.clientX - this.#lastPointerX) / elapsed) * 1000;
    }
    this.#lastPointerX = event.clientX;
    this.#lastPointerTime = event.timeStamp;

    if (Math.abs(info.delta.x) > 8) {
      this.#suppressClickUntil = Date.now() + 350;
    }
  }

  @action
  onDragEnd(event, info) {
    if (!info.moved) {
      return;
    }

    const directionFactor = this.isRtl ? 1 : -1;
    const logicalDelta = this.dragOffset * directionFactor;
    const logicalVelocity = this.#pointerVelocity * directionFactor;
    const projectedDelta =
      logicalDelta + logicalVelocity * FLICK_PROJECTION_SECONDS;
    const distanceThreshold = this.#viewportWidth * 0.2;
    let step = 0;

    if (
      projectedDelta > distanceThreshold ||
      logicalVelocity > MIN_FLICK_VELOCITY
    ) {
      step = 1;
    } else if (
      projectedDelta < -distanceThreshold ||
      logicalVelocity < -MIN_FLICK_VELOCITY
    ) {
      step = -1;
    }

    const nextPosition = Math.min(
      this.maxPosition,
      Math.max(0, this.#dragStartPosition + step)
    );
    const oldBase =
      directionFactor * this.#dragStartPosition * this.#viewportWidth;
    const newBase = directionFactor * nextPosition * this.#viewportWidth;

    this.dragOffset += oldBase - newBase;
    this.currentPosition = nextPosition;
    this.isSettling = true;
    this.#startSpring(this.#pointerVelocity);

    if (nextPosition !== this.#dragStartPosition) {
      this.announcePosition();
    }
  }

  @action
  onDragCancel() {
    this.isSettling = true;
    this.#startSpring(0);
  }

  @action
  preventDraggedClick(event) {
    if (Date.now() < this.#suppressClickUntil) {
      event.preventDefault();
      event.stopPropagation();
    }
  }

  #startSpring(initialVelocity) {
    this.#cancelSpring();

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.dragOffset = 0;
      this.isSettling = false;
      return;
    }

    let lastTime;
    let velocity = initialVelocity;

    const settle = (time) => {
      const elapsed = lastTime ? Math.min((time - lastTime) / 1000, 0.032) : 0;
      lastTime = time;

      if (elapsed > 0) {
        const acceleration =
          -SPRING_STIFFNESS * this.dragOffset - SPRING_DAMPING * velocity;
        velocity += acceleration * elapsed;
        this.dragOffset += velocity * elapsed;
      }

      if (Math.abs(this.dragOffset) < 0.5 && Math.abs(velocity) < 5) {
        this.dragOffset = 0;
        this.isSettling = false;
        this.#animationFrame = undefined;
        return;
      }

      this.#animationFrame = requestAnimationFrame(settle);
    };

    this.#animationFrame = requestAnimationFrame(settle);
  }

  #cancelSpring() {
    if (this.#animationFrame) {
      cancelAnimationFrame(this.#animationFrame);
      this.#animationFrame = undefined;
    }
  }

  <template>
    <div
      class="tlp-featured-topics__carousel"
      aria-label={{i18n (themePrefix "tlp.featured_topics.label")}}
      role="region"
    >
      <DButton
        class="tlp-featured-topics__navigation --previous"
        @action={{this.previous}}
        @disabled={{this.atStart}}
        @icon={{this.previousIcon}}
        @title={{themePrefix "tlp.featured_topics.previous"}}
      />
      <div
        class="tlp-featured-topics__viewport"
        tabindex="0"
        {{dOnResize this.onResize (hash delay=100 immediate=true)}}
        {{on "click" this.preventDraggedClick capture=true}}
        {{on "keydown" this.onKeydown}}
        {{dPointerDrag
          onDragStart=this.onDragStart
          onDrag=this.onDrag
          onDragEnd=this.onDragEnd
          onDragCancel=this.onDragCancel
          draggingClass="is-dragging"
          threshold=4
          touchAction="pan-y"
        }}
      >
        <div
          class="tlp-featured-topics__track
            {{if this.isSettling 'is-settling'}}"
          style={{this.trackStyle}}
        >
          {{#each this.topics as |topic|}}
            <div class="tlp-featured-topics__slide">
              {{yield topic}}
            </div>
          {{/each}}
        </div>
      </div>
      <DButton
        class="tlp-featured-topics__navigation --next"
        @action={{this.next}}
        @disabled={{this.atEnd}}
        @icon={{this.nextIcon}}
        @title={{themePrefix "tlp.featured_topics.next"}}
      />
    </div>
    <div class="tlp-featured-topics__position">
      <div class="tlp-featured-topics__position-dots">
        <span class="sr-only">{{this.positionLabel}}</span>
        {{#each this.positionDots key="id" as |dot|}}
          <span
            aria-hidden="true"
            class="tlp-featured-topics__position-dot
              {{if dot.isActive 'is-active'}}"
          ></span>
        {{/each}}
      </div>

      {{#if (has-block "positionTrailing")}}
        <div class="tlp-featured-topics__position-trailing">
          {{yield to="positionTrailing"}}
        </div>
      {{/if}}
    </div>
  </template>
}
