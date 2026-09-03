abstract class DataMapper<Entity, Dto> {
  Entity toEntity(Dto dto);
  Dto toDto(Entity entity);
}
