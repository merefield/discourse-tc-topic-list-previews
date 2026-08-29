export default function migrate(settings) {
  if (settings.has("topic_list_featured_images_tag_show")) {
    settings.set(
      "topic_list_featured_images_source_show",
      settings.get("topic_list_featured_images_tag_show")
    );
    settings.delete("topic_list_featured_images_tag_show");
  }

  return settings;
}
