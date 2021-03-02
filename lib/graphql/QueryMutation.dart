class QueryMutation {
  static String login(String email, String name) {
    return """
      mutation{
        login(
          userEmail:"$email"
          name:"$name"
        ){
          user{
            user_idx
            user_name
            user_email
          }
          token
        }
      }
    """;
  }

  static String createRest(String name, String address) {
    return """
      mutation{
        createRest(
          res_name:"$name"
          res_address:"$address"
        ){
          resultCount
        }
      }
    """;
  }

  static String getRestsList() {
    return """
      query{
        getRestsList(){
          res_idx
          res_name
          res_address
          created_date
          modified_date
        }
      }
    """;
  }

  static String getRest(String _resId) {
    return """
      query{
        getRest(
          res_idx:"$_resId"
        ){
          res_name
          res_address
          avgs
        }
      }
    """;
  }

  static String createComm(
      String comment, String userIdx, String resIdx, num score) {
    return """
      mutation{
        createComm(
          com_content: "$comment"
          com_user: "$userIdx"
          com_restaurant: "$resIdx"
          com_score: $score
        ){
          resultCount
        }
      }
    """;
  }

  static String getComms(String resIdx) {
    return """
      query{
        getComms(res_idx:"$resIdx"){
          com_idx
          com_score
          com_content
          com_restaurant
          user_name
        }
      }
    """;
  }
}
