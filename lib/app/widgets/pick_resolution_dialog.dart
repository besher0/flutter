// await showDialog(
// context: context,
// builder: (context) {
// return Column(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// AlertDialog(
// title: Text(
// "اختر دقة للتحميل",
// textAlign: TextAlign.center,
// ),
// content: BlocBuilder<HomeBloc, HomeState>(
// builder: (context, state) {
// if (state.getResolutionsStatus ==
// GetResolutionsStatus.loading) {
// return Center(child: AssasAppLoader());
// }
// if (state.getResolutionsStatus ==
// GetResolutionsStatus.failure) {
// return Center(
// child: TryAgainWidget(
// onTap: () {
// BlocProvider.of<HomeBloc>(context).add(
// GetResolutionsEvent(
// videoId:
// widget.videoModel.video720!.videoId!,
// libraryId: widget
//     .videoModel.video720!.libraryId!,
// ),
// );
// },
// ),
// );
// }
// return Column(
// spacing: 10,
// children: List.generate(
// state.resolutions.length,
// (index) => InkWell(
// onTap: () async{
// if(selectedResolution != state.resolutions[index]){
// await DownloadingServiceWithEncrypting.deleteFileFromTemp(videoName: videoName);
// }
// selectedResolution = state.resolutions[index];
// Navigator.pop(context);
// },
// child: Padding(
// padding: const EdgeInsets.all(8.0),
// child: Text(state.resolutions[index] + 'p'),
// ),
// ),
// ),
// );
// },
// ),
// ),
// ],
// );
// },
// );
