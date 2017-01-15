sub {
  my $c = shift;
  my $data = shift;
  use JSON;
  $data->reply(encode_json($data->data));
  return 1;
}
