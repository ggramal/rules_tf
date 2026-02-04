## Usage Examples

This section covers the most common ways to work with the project during development and testing.

## Notes on State and Locking

For testing, we use the **`local` Terraform state backend**.  
Because Bazel build and test actions run in a sandboxed environment, they cannot modify source files. As a result, Terraform locking must be disabled:

```hcl
lock = false
```

This setting is **only intended for local testing**.  
In other environments, you should remove `lock = false` and enable state locking as usual.

## How to Run
- **Create local tf state files. (Needs to be excuted only once)**
  ```sh
  bazel run //:create_local_states
  ```

- **Build all targets**
  ```sh
  bazel build //...
  ```

- **Run all tests**
  ```sh
  bazel test //...
  ```

- **Run all `apply` rules**
  ```sh
  bazel run //:apply
  ```

- **Fix all lint issues**
  ```sh
   bazel run //:lint_fix_tf
  ```

- **Binary tf execution**
  ```sh
   bazel run //tf_binary:tf version
  ```
