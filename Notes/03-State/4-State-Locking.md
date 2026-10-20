# State Locking

State Locking prevents multiple Terraform operations from modifying the same state file at the same time.

Terraform state is a shared resource. When Terraform runs `terraform apply` it:
- Reads State
- Modifies Infrastructure
- Updates State

If two users modify state simultaneously then problems like below can occur.
- Lost Updates
- Corrupted State
- Inconsistent Infrastructure

## How State Locking Works

Terraform acquires a lock before modifying state.

```text
terraform apply
      ↓
Acquire Lock
      ↓
Read State
      ↓
Modify Infrastructure
      ↓
Update State
      ↓
Release Lock
```
Only one Terraform process can hold the lock. Operations That Use Locks
1. `terraform apply`
2. `terraform destroy`
3. `terraform import`
4. `terraform state mv`
5. `terraform state rm`

Any operation that modifies state generally acquires a lock.

> Local State Locking, ***Local state uses filesystem locking.***

![locking](https://cdn.prod.website-files.com/644656ba41efb6b601e93ca6/6735f655315efd56f90bb861_AD_4nXctUOfJ5AbeJovQHhBGf5Rvl1NZ3vjLSdEi8rimqH9OED-feB10FgZTtirKZe5ZN1GyF2bRIWN2yPchIilUd7vsDdtFH0dp6qJuhDXxDC5i5_JuJIY78xlpi1Th36wzGK4VdDnCJA.png)

## Remote State Locking
Remote backends provide locking support.

```text
GCS
S3 + DynamoDB
Terraform Cloud
Azure Storage
```
Terraform coordinates access across multiple users.

---

## Lock Timeout & Configuring Lock Timeout
Sometimes another user already holds the lock. By default, *Terraform dosen't meaning it will exit with an error the exact moment it encounters a pre-existing lock.*

- **CI/CD Pipelines**: Essential in shared automation environments (e.g., GitHub Actions, GitLab CI) where multiple developer workflows might trigger concurrent runs.
- **Graceful Queuing**: Instead of breaking a build pipeline immediately, a 5m timeout allows a secondary pipeline to seamlessly pick up once the first run completes.
- **Team Coordination**: Reduces friction within engineering teams by smoothly navigating overlapping local executions.

The `-lock-timeout=DURATION` flag instructs Terraform to continually retry acquiring a state lock for a specified period of time instead of failing immediately. 

## Lock Information

Failed lock example: *Error acquiring the state lock*

Terraform usually shows:
- Who Holds The Lock
- Operation
- Timestamp

```txt
User: xyz
Operation: Apply
Created: 2026-09-02
```
Useful for troubleshooting.

---

## Stale Locks

Sometimes a lock remains even though the original process no longer exists.
- Laptop Crash
- Terminal Closed
- Network Failure
- CI/CD Terminated

State remains locked.

## Force Unlock

Terraform provides a `LOCK_ID`.

You can fix a stale Terraform state lock by running `terraform force-unlock <LOCK_ID>` using the ID provided in your error message.
- `terraform force-unlock 12345678-90ab-cdef`, Removes lock manually.

> Only use ***force-unlock***, when you are sure 'No Terraform Operation Is Running' otherwise **State Corruption** may occur. 

## CI/CD and State Locking

```text
Pipeline A
      ↓
terraform apply
# Lock acquired.

Pipeline B:
    ↓
terraform apply
# Must wait.
```
- Prevents Concurrent Deployments
- Prevents State Corruption
- Ensures Consistency

---

## Common Locking Errors

#### 1. Error Acquiring State Lock
- Another Apply Running
- Another Destroy Running
- CI/CD Job Running

#### 2. Stale Lock
- Operation Crashed
- State remains locked.
-  Use: `terraform force-unlock` carefully.

#### 3. Lock Timeout
- Timed out waiting for state lock

#### 4. Disabling Locking
- `terraform apply -lock=false`
- This is dangerous

---

***Interview Keywords:***
```text
State Locking
Concurrency Control
Race Conditions
State Corruption
force-unlock
lock-timeout
Remote State
```