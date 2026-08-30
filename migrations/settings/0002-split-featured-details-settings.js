export default function migrate(settings) {
  if (settings.has("topic_list_featured_excerpt")) {
    const excerptLength = settings.get("topic_list_featured_excerpt");
    settings.set("topic_list_featured_excerpt_desktop", excerptLength);
    settings.set("topic_list_featured_excerpt_mobile", excerptLength);
    settings.delete("topic_list_featured_excerpt");
  }

  if (settings.has("topic_list_featured_details_always_show")) {
    const previousPresentation = settings.get(
      "topic_list_featured_details_always_show"
    );
    const desktopPresentation =
      previousPresentation === "always" ? "Always over" : "Over on hover";

    settings.set("topic_list_featured_details_desktop", desktopPresentation);
    settings.set("topic_list_featured_details_mobile", "Over");
    settings.delete("topic_list_featured_details_always_show");
  }

  return settings;
}
