part of '../wonders_login_screen.dart';

/// Autopopulating textfield used for searching for Artifacts by name.
class _LoginInput extends StatelessWidget {
  const _LoginInput({Key? key, required this.onSubmit}) : super(key: key);
  final void Function(String) onSubmit;
  //final WonderData wonder;

  void _handleLoginTap() {
    //appRouter.push(ScreenPaths.home);
    //appRouter.push(ScreenPaths.medias);
    appRouter.push(ScreenPaths.wonderDetails(WonderType.chichenItza));
  }

  void _handleGalleryTap() {
    //appRouter.push(ScreenPaths.home);
    appRouter.push(ScreenPaths.upload);
    //appRouter.push(ScreenPaths.wonderDetails(WonderType.chichenItza));
  }

  void _handleChatTap1() {
    //appRouter.push(ScreenPaths.home);
    appRouter.push(ScreenPaths.chat);
    //appRouter.push(ScreenPaths.wonderDetails(WonderType.chichenItza));
  }

  void _handleChatTap2() {
    appRouter.push(ScreenPaths.chat2);
  }

  @override
  Widget build(BuildContext context) {
    Color captionColor = $styles.colors.caption;

    return Column(
      children: [
        Gap($styles.insets.xs),
        Gap($styles.insets.xs),
        Gap($styles.insets.xs),
        Gap($styles.insets.xs),
        Gap($styles.insets.xs),
        Gap($styles.insets.xs),
        Gap($styles.insets.xs),
        Gap($styles.insets.xs),
        Gap($styles.insets.xs),
        Container(
          padding: EdgeInsets.symmetric(horizontal: $styles.insets.sm),
          child: Container(
            //width: 256,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 5.0,
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(
                    "https://androidsignageappfa1996dc2bbf42b2ad446d846fc5ca155413-dev.s3.ap-northeast-1.amazonaws.com/deploy/mi_iewr82sd.png"),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        Gap($styles.insets.xs),

        /*
        Container(
          height: $styles.insets.xl,
            decoration: BoxDecoration(
              color: $styles.colors.offWhite,
              borderRadius: BorderRadius.circular($styles.insets.xs),
            ),
            child: TextField(
              autofocus: true,
              onSubmitted: onSubmit,
              style: TextStyle(color: captionColor),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.verified_user, color: $styles.colors.caption),
                isDense: true,
                contentPadding: EdgeInsets.all($styles.insets.xs),
                labelStyle: TextStyle(color: captionColor),
                hintStyle: TextStyle(color: captionColor.withOpacity(0.5)),
                prefixStyle: TextStyle(color: captionColor),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                hintText: $strings.searchInputHintSearch,
              ),
            ),
        ),

        Gap($styles.insets.xs),

        Container(
          height: $styles.insets.xl,
          decoration: BoxDecoration(
            color: $styles.colors.offWhite,
            borderRadius: BorderRadius.circular($styles.insets.xs),
          ),
          child: TextField(
            autofocus: true,
            onSubmitted: onSubmit,
            style: TextStyle(color: captionColor),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.password, color: $styles.colors.caption),
              isDense: true,
              contentPadding: EdgeInsets.all($styles.insets.xs),
              labelStyle: TextStyle(color: captionColor),
              hintStyle: TextStyle(color: captionColor.withOpacity(0.5)),
              prefixStyle: TextStyle(color: captionColor),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
              hintText: $strings.searchInputHintSearch,
            ),
          ),
        ),
         */

        Gap($styles.insets.xs),
        AppBtn.from(
          text: "data",
          icon: Icons.login,
          expand: true,
          onPressed: _handleLoginTap,
        ),
        Gap($styles.insets.xs),
        AppBtn.from(
          text: "test photo_gallery ",
          icon: Icons.login,
          expand: true,
          onPressed: _handleGalleryTap,
        ),
        AppBtn.from(
          text: "test chat1 ",
          icon: Icons.login,
          expand: true,
          onPressed: _handleChatTap1,
        ),
        Gap($styles.insets.xs),
        AppBtn.from(
          text: "test chat2 ",
          icon: Icons.login,
          expand: true,
          onPressed: _handleChatTap2,
        ),
      ],
    );
  }

  Widget _buildSuggestionTitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.all($styles.insets.xs).copyWith(top: 0),
      margin: EdgeInsets.only(bottom: $styles.insets.xxs),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: $styles.colors.greyStrong.withOpacity(0.1)))),
      child: CenterLeft(
        child: Text(
          $strings.searchInputTitleSuggestions.toUpperCase(),
          overflow: TextOverflow.ellipsis,
          textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
          style: $styles.text.title2.copyWith(color: $styles.colors.black),
        ),
      ),
    );
  }

  Widget _buildSuggestion(BuildContext context, String suggestion, VoidCallback onPressed) {
    return AppBtn.basic(
      semanticLabel: suggestion,
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.all($styles.insets.xs),
        child: CenterLeft(
          child: Text(
            suggestion,
            overflow: TextOverflow.ellipsis,
            textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false),
            style: $styles.text.bodySmall.copyWith(color: $styles.colors.greyStrong),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, TextEditingController textController, FocusNode focusNode, _) {
    Color captionColor = $styles.colors.caption;
    return Container(
      height: $styles.insets.xl,
      decoration: BoxDecoration(
        color: $styles.colors.offWhite,
        borderRadius: BorderRadius.circular($styles.insets.xs),
      ),
      child: Row(children: [
        Gap($styles.insets.xs * 1.5),
        Icon(Icons.search, color: $styles.colors.caption),
        Expanded(
          child: TextField(
            onSubmitted: onSubmit,
            controller: textController,
            focusNode: focusNode,
            style: TextStyle(color: captionColor),
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all($styles.insets.xs),
              labelStyle: TextStyle(color: captionColor),
              hintStyle: TextStyle(color: captionColor.withOpacity(0.5)),
              prefixStyle: TextStyle(color: captionColor),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
              hintText: $strings.searchInputHintSearch,
            ),
          ),
        ),
        Gap($styles.insets.xs),
        ValueListenableBuilder(
          valueListenable: textController,
          builder: (_, value, __) => Visibility(
            visible: textController.value.text.isNotEmpty,
            child: Padding(
              padding: EdgeInsets.only(right: $styles.insets.xs),
              child: CircleIconBtn(
                bgColor: $styles.colors.caption,
                color: $styles.colors.white,
                icon: AppIcons.close,
                semanticLabel: $strings.searchInputSemanticClear,
                size: $styles.insets.lg,
                iconSize: $styles.insets.sm,
                onPressed: () {
                  textController.clear();
                  onSubmit('');
                },
              ),
            ),
          ),
        )
      ]),
    );
  }
}
