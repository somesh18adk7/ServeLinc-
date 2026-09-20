// ServeLinc management authorization policies.
//
// The application should construct:
//   principal: User with { role, tenant }
//   resource: Quota with { tenant }
// and use the matching action for each management RPC.

// Platform administrators can read and change every quota.
permit (
    principal,
    action in [Action::"GetQuota", Action::"SetQuota"],
    resource
)
when {
    principal.role == "admin"
};

// Tenant operators can inspect quotas belonging to their tenant.
permit (
    principal,
    action == Action::"GetQuota",
    resource
)
when {
    principal.role == "operator" &&
    principal.tenant == resource.tenant
};

// Tenant operators may update only their own tenant's quota.
permit (
    principal,
    action == Action::"SetQuota",
    resource
)
when {
    principal.role == "operator" &&
    principal.tenant == resource.tenant
};

// No policy grants access to unknown roles or cross-tenant resources.
