import { themePrefix } from "virtual:theme";
import PreferenceCheckbox from "discourse/components/preference-checkbox";
import { i18n } from "discourse-i18n";

<template>
  <label class="control-label">
    {{i18n (themePrefix "tlp.user_prefs.title")}}
  </label>
  <PreferenceCheckbox
    @labelKey={{themePrefix "tlp.user_prefs.prefer_low_res_thumbnails"}}
    @checked={{@model.custom_fields.tlp_user_prefs_prefer_low_res_thumbnails}}
  />
</template>
