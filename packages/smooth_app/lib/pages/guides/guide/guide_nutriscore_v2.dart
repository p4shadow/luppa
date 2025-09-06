import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/guides/helpers/guides_content.dart';
import 'package:smooth_app/pages/guides/helpers/guides_footer.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
<<<<<<< HEAD
import 'package:smooth_app/resources/app_icons.dart' as icons;
=======
import 'package:smooth_app/resources/app_icons.dart';
>>>>>>> 33fe57b5c (Primer commit)

class GuideNutriscoreV2 extends StatelessWidget {
  const GuideNutriscoreV2({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesPage(
      pageName: 'NutriscoreV2',
      header: const _NutriscoreHeader(),
      body: const <Widget>[
        _NutriScoreSection1(),
        _NutriScoreSection2(),
        _NutriScoreSection3(),
        _NutriScoreSection4(),
        _NutriScoreSection5(),
      ],
      footer: SliverToBoxAdapter(
        child: GuidesFooter(
<<<<<<< HEAD
=======
          shareMessage: appLocalizations.guide_nutriscore_v2_share_message,
>>>>>>> 33fe57b5c (Primer commit)
          shareUrl: appLocalizations.guide_nutriscore_v2_share_link,
        ),
      ),
    );
  }
}

class _NutriscoreHeader extends StatelessWidget {
  const _NutriscoreHeader();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesHeader(
      title: appLocalizations.guide_nutriscore_v2_title,
      illustration: const _NutriScoreHeaderIllustration(),
    );
  }
}

class _NutriScoreHeaderIllustration extends StatelessWidget {
  const _NutriScoreHeaderIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 32,
          child: SvgPicture.asset(
            SvgCache.getAssetsCacheForNutriscore(NutriScoreValue.a, false),
          ),
        ),
<<<<<<< HEAD
        const Expanded(flex: 28, child: icons.Arrow.down(color: Colors.white)),
=======
        const Expanded(flex: 28, child: Arrow.down(color: Colors.white)),
>>>>>>> 33fe57b5c (Primer commit)
        Expanded(
          flex: 40,
          child: SvgPicture.asset(
            SvgCache.getAssetsCacheForNutriscore(NutriScoreValue.a, true),
          ),
        ),
      ],
    );
  }
}

class _NutriScoreSection1 extends StatelessWidget {
  const _NutriScoreSection1();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_nutriscore_v2_what_is_nutriscore_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations
              .guide_nutriscore_v2_what_is_nutriscore_paragraph1,
        ),
        GuidesText(
          text: appLocalizations
              .guide_nutriscore_v2_what_is_nutriscore_paragraph2,
        ),
        GuidesImage(
          imagePath: SvgCache.getAssetsCacheForNutriscore(
            NutriScoreValue.a,
            false,
          ),
          caption: appLocalizations.guide_nutriscore_v2_nutriscore_a_caption,
          desiredWidthPercent: 0.30,
        ),
      ],
    );
  }
}

class _NutriScoreSection2 extends StatelessWidget {
  const _NutriScoreSection2();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_nutriscore_v2_why_v2_title,
      content: <Widget>[
        GuidesText(text: appLocalizations.guide_nutriscore_v2_why_v2_intro),
        GuidesTitleWithText(
          title: appLocalizations.guide_nutriscore_v2_why_v2_arg1_title,
<<<<<<< HEAD
          icon: const icons.Milk(),
=======
          icon: const Milk(),
>>>>>>> 33fe57b5c (Primer commit)
          text: appLocalizations.guide_nutriscore_v2_why_v2_arg1_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nutriscore_v2_why_v2_arg2_title,
<<<<<<< HEAD
          icon: const icons.Soda.unhappy(),
=======
          icon: const Soda.unhappy(),
>>>>>>> 33fe57b5c (Primer commit)
          text: appLocalizations.guide_nutriscore_v2_why_v2_arg2_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nutriscore_v2_why_v2_arg3_title,
<<<<<<< HEAD
          icon: const icons.Salt(),
=======
          icon: const Salt(),
>>>>>>> 33fe57b5c (Primer commit)
          text: appLocalizations.guide_nutriscore_v2_why_v2_arg3_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nutriscore_v2_why_v2_arg4_title,
<<<<<<< HEAD
          icon: const icons.Fish(),
=======
          icon: const Fish(),
>>>>>>> 33fe57b5c (Primer commit)
          text: appLocalizations.guide_nutriscore_v2_why_v2_arg4_text,
        ),
        GuidesTitleWithText(
          title: appLocalizations.guide_nutriscore_v2_why_v2_arg5_title,
<<<<<<< HEAD
          icon: const icons.Chicken(),
=======
          icon: const Chicken(),
>>>>>>> 33fe57b5c (Primer commit)
          text: appLocalizations.guide_nutriscore_v2_why_v2_arg5_text,
        ),
      ],
    );
  }
}

class _NutriScoreSection3 extends StatelessWidget {
  const _NutriScoreSection3();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_nutriscore_v2_new_logo_title,
      content: <Widget>[
        GuidesText(text: appLocalizations.guide_nutriscore_v2_new_logo_text),
        GuidesImage(
          imagePath: SvgCache.getAssetsCacheForNutriscore(
            NutriScoreValue.a,
            true,
          ),
          caption: appLocalizations.guide_nutriscore_v2_new_logo_image_caption,
          desiredWidthPercent: 0.30,
        ),
      ],
    );
  }
}

class _NutriScoreSection4 extends StatelessWidget {
  const _NutriScoreSection4();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_nutriscore_v2_where_title,
      content: <Widget>[
        GuidesText(text: appLocalizations.guide_nutriscore_v2_where_paragraph1),
        GuidesText(text: appLocalizations.guide_nutriscore_v2_where_paragraph2),
        GuidesIllustratedText(
          text: appLocalizations.guide_nutriscore_v2_where_paragraph3,
          imagePath: 'assets/app/release_icon_light_transparent_no_border.svg',
          desiredWidthPercent: 0.15,
        ),
      ],
    );
  }
}

class _NutriScoreSection5 extends StatelessWidget {
  const _NutriScoreSection5();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return GuidesParagraph(
      title: appLocalizations.guide_nutriscore_v2_unchanged_title,
      content: <Widget>[
        GuidesText(
          text: appLocalizations.guide_nutriscore_v2_unchanged_paragraph1,
        ),
        GuidesText(
          text: appLocalizations.guide_nutriscore_v2_unchanged_paragraph2,
        ),
      ],
    );
  }
}
