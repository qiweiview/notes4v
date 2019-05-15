# SpringData Jpa分页
1. 继承PagingAndSortingRepository
```
public interface UserRepository extends PagingAndSortingRepository<User, Integer> {

}
```
2.传入Pageable参数查询
```
Pageable pageable =PageRequest.of(page, size, Sort.by(Direction.DESC, "id"));
Page<User> result=userRepository.findAll(pageable);
```