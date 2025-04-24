sealed class EditItemState{

}

class InitialState extends EditItemState{

}

class UploadingState extends EditItemState{

}

class UploadedState extends EditItemState{

}

class UploadFailedState extends EditItemState{

}


class DeletingState extends EditItemState{

}

class DeletedState extends EditItemState{

}

class DeletingFailedState extends EditItemState{

}