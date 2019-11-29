export default ({ IDL }) => {
 const actor_anon = new IDL.ActorInterface({
  'greet': IDL.Func([IDL.Text], [IDL.Text])});
 return actor_anon;
};
