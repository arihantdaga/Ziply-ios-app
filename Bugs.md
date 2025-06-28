- [x] In the select photo screen, When we change the date filter, the selected state is not highlited until we also change photo size slider. Seems like UI is updated only after we change the values of the size slider. 
- [x] After clicking on Find Photos to compress, we are waiting before changing the page, we should move to the next page imidiately and show a loader, while in the UI keep increasing count and total size of the photos we found. Remove the loader once we have finished scanning. When doing this, make sure that if user clicks back button at some point, we should stop the process of searching through files.
- [x] Photo search UI not updating on first navigation - fixed by moving search initiation to PreviewResultsView's onAppear 
- [x] The app is duplicating photos, every time we are running compression, it's creating a new photo, not replacing existing ones. 

