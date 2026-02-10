class CreateDatasetRequest {
  const CreateDatasetRequest({
    required this.parentDataset,
    required this.datasetName,
    required this.encrypted,
    this.passphrase,
  });

  final String parentDataset;
  final String datasetName;
  final bool encrypted;
  final String? passphrase;
}
