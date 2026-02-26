# Server-Side Rendering with Next.js

[← Back to Phase 6](README.md) | [Roadmap](../README.md)

## SSR vs CSR vs SSG vs ISR

| Mode | When HTML is generated | Use Case |
|------|----------------------|----------|
| CSR (React SPA) | Client, on load | Dashboards, apps behind auth |
| SSR | Server, per request | SEO pages with dynamic data |
| SSG | Build time | Blogs, docs, marketing pages |
| ISR | Build + revalidate | E-commerce catalogs, news |

---

## Next.js App Router

```bash
npx create-next-app@latest my-app --typescript --tailwind --app
```

```
my-app/
├── app/
│   ├── layout.tsx         # root layout (always server component)
│   ├── page.tsx           # / route
│   ├── (auth)/            # route group (no URL segment)
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── dashboard/
│   │   ├── layout.tsx     # dashboard layout
│   │   ├── page.tsx       # /dashboard
│   │   └── users/
│   │       ├── page.tsx   # /dashboard/users
│   │       └── [id]/
│   │           └── page.tsx  # /dashboard/users/[id]
│   └── api/
│       └── users/
│           └── route.ts   # API route handler
├── components/
└── lib/
```

---

## Server Components (Default)

Server Components run on the server — no client-side JS, direct DB/API access.

```tsx
// app/dashboard/users/page.tsx — Server Component
import { userService } from '@/lib/userService';

// No 'use client' directive = Server Component
export default async function UsersPage({
  searchParams,
}: {
  searchParams: { page?: string; search?: string };
}) {
  // Direct service call — no API round-trip
  const data = await userService.getAll({
    page: Number(searchParams.page ?? 1),
    search: searchParams.search ?? '',
  });

  return (
    <main>
      <h1>Users</h1>
      {/* Server component passes data to client components */}
      <UserSearch />                    {/* client component */}
      <UserTable users={data.items} />  {/* can be server */}
      <Pagination total={data.total} /> {/* client component */}
    </main>
  );
}

// Metadata for SEO — generated server-side
export const metadata = {
  title: 'Users | My App',
  description: 'Manage application users',
};
```

---

## Client Components

```tsx
// components/UserSearch.tsx
'use client';  // opt-in to client rendering

import { useRouter, useSearchParams } from 'next/navigation';
import { useTransition } from 'react';

export function UserSearch() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [isPending, startTransition] = useTransition();

  const handleSearch = (term: string) => {
    const params = new URLSearchParams(searchParams);
    params.set('search', term);
    params.set('page', '1');
    startTransition(() => {
      router.push(`?${params.toString()}`);
    });
  };

  return (
    <input
      defaultValue={searchParams.get('search') ?? ''}
      onChange={(e) => handleSearch(e.target.value)}
      placeholder="Search users..."
    />
  );
}
```

---

## Route Handlers (API Routes)

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { userService } from '@/lib/userService';
import { getServerSession } from 'next-auth';

export async function GET(request: NextRequest) {
  const session = await getServerSession();
  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const { searchParams } = new URL(request.url);
  const data = await userService.getAll({
    page: Number(searchParams.get('page') ?? 1),
    search: searchParams.get('search') ?? '',
  });

  return NextResponse.json(data, {
    headers: { 'Cache-Control': 's-maxage=60, stale-while-revalidate=300' },
  });
}
```

---

## SEO Optimization

```tsx
// Dynamic metadata
export async function generateMetadata({ params }: { params: { id: string } }) {
  const user = await userService.getById(params.id);
  return {
    title: `${user.name} | My App`,
    description: `Profile page for ${user.name}`,
    openGraph: {
      title: user.name,
      images: [user.avatarUrl],
    },
  };
}

// Sitemap
// app/sitemap.ts
export default async function sitemap() {
  const users = await userService.getAll({ pageSize: 1000 });
  return [
    { url: 'https://example.com', lastModified: new Date() },
    ...users.items.map((u) => ({
      url: `https://example.com/users/${u.id}`,
      lastModified: new Date(u.createdAt),
    })),
  ];
}
```

---

## Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Next.js App Router](https://nextjs.org/docs/app)
- [Vercel Deployment](https://vercel.com/docs)

---

→ [Mobile Advanced](mobile-advanced.md) | [Phase 6 Overview](README.md)
