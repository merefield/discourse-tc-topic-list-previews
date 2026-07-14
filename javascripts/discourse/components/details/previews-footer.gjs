import PreviewsActions from "./footer/previews-actions";
import PreviewsMeta from "./footer/previews-meta";
import PreviewsUsers from "./footer/previews-users";

export default <template>
  <div class="topic-footer">
    <PreviewsMeta @topic={{@topic}} />
    <PreviewsUsers @topic={{@topic}} />
    <PreviewsActions @topic={{@topic}} />
  </div>
</template>
