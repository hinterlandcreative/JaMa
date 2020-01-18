abstract class DTO {
  int id = -1;

  DTO();
  
  DTO.fromMap(Map<String, dynamic> map);

  Map<String, dynamic> toMap();
}