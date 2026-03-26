import DiscourseRecommendedTheme from "@discourse/lint-configs/eslint-theme";

export default [
  {
    ignores: ["assets/imagesloaded.js"],
  },
  ...DiscourseRecommendedTheme,
];
