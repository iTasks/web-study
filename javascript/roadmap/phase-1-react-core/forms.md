# Forms in React

[← Back to Phase 1](README.md) | [Roadmap](../README.md)

## Controlled Forms

In React, form elements are kept in sync with component state — React is the single source of truth.

```tsx
import { useState } from 'react';

interface LoginForm {
  email: string;
  password: string;
}

function LoginPage() {
  const [form, setForm] = useState<LoginForm>({ email: '', password: '' });
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();       // prevent default browser submit
    setLoading(true);
    try {
      await login(form);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} noValidate>
      <input
        type="email"
        name="email"
        value={form.email}
        onChange={handleChange}
        required
      />
      <input
        type="password"
        name="password"
        value={form.password}
        onChange={handleChange}
        required
        minLength={8}
      />
      {error && <p role="alert">{error}</p>}
      <button type="submit" disabled={loading}>
        {loading ? 'Signing in…' : 'Sign in'}
      </button>
    </form>
  );
}
```

---

## Validation

### Manual Validation

```tsx
interface FieldErrors {
  email?: string;
  password?: string;
}

function validate(form: LoginForm): FieldErrors {
  const errors: FieldErrors = {};

  if (!form.email) {
    errors.email = 'Email is required';
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
    errors.email = 'Enter a valid email address';
  }

  if (!form.password) {
    errors.password = 'Password is required';
  } else if (form.password.length < 8) {
    errors.password = 'Password must be at least 8 characters';
  }

  return errors;
}

// Usage in component
const [touched, setTouched] = useState<Record<string, boolean>>({});
const errors = validate(form);
const isValid = Object.keys(errors).length === 0;

const handleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
  setTouched((prev) => ({ ...prev, [e.target.name]: true }));
};
```

---

## React Hook Form (Recommended)

The most popular form library — minimal re-renders, built-in validation, TypeScript-first.

```bash
npm install react-hook-form
```

```tsx
import { useForm, SubmitHandler } from 'react-hook-form';

interface RegisterForm {
  name: string;
  email: string;
  password: string;
  confirmPassword: string;
}

function RegisterPage() {
  const {
    register,
    handleSubmit,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<RegisterForm>({ mode: 'onBlur' });

  const password = watch('password');

  const onSubmit: SubmitHandler<RegisterForm> = async (data) => {
    await registerUser(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('name', { required: 'Name is required' })}
        placeholder="Full name"
      />
      {errors.name && <span>{errors.name.message}</span>}

      <input
        {...register('email', {
          required: 'Email is required',
          pattern: {
            value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
            message: 'Enter a valid email',
          },
        })}
        type="email"
        placeholder="Email"
      />
      {errors.email && <span>{errors.email.message}</span>}

      <input
        {...register('password', {
          required: 'Password is required',
          minLength: { value: 8, message: 'Minimum 8 characters' },
        })}
        type="password"
        placeholder="Password"
      />
      {errors.password && <span>{errors.password.message}</span>}

      <input
        {...register('confirmPassword', {
          validate: (val) => val === password || 'Passwords do not match',
        })}
        type="password"
        placeholder="Confirm password"
      />
      {errors.confirmPassword && <span>{errors.confirmPassword.message}</span>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating account…' : 'Create account'}
      </button>
    </form>
  );
}
```

### With Zod Schema Validation

```bash
npm install zod @hookform/resolvers
```

```tsx
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';

const schema = z
  .object({
    email: z.string().email('Enter a valid email'),
    password: z.string().min(8, 'Minimum 8 characters'),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: 'Passwords do not match',
    path: ['confirmPassword'],
  });

type FormData = z.infer<typeof schema>;

function RegisterForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });
  // ...
}
```

---

## Formik

Alternative to React Hook Form — context-based, more verbose but very explicit.

```bash
npm install formik yup
```

```tsx
import { Formik, Form, Field, ErrorMessage } from 'formik';
import * as Yup from 'yup';

const validationSchema = Yup.object({
  email: Yup.string().email('Invalid email').required('Required'),
  password: Yup.string().min(8, 'Minimum 8 characters').required('Required'),
});

function LoginForm() {
  return (
    <Formik
      initialValues={{ email: '', password: '' }}
      validationSchema={validationSchema}
      onSubmit={async (values, { setSubmitting }) => {
        await login(values);
        setSubmitting(false);
      }}
    >
      {({ isSubmitting }) => (
        <Form>
          <Field type="email" name="email" />
          <ErrorMessage name="email" component="span" />

          <Field type="password" name="password" />
          <ErrorMessage name="password" component="span" />

          <button type="submit" disabled={isSubmitting}>Submit</button>
        </Form>
      )}
    </Formik>
  );
}
```

---

## Library Comparison

| Feature | React Hook Form | Formik |
|---------|----------------|--------|
| Re-renders | Minimal (uncontrolled by default) | More (context-based) |
| Bundle size | ~9 KB | ~15 KB |
| Validation | Native + resolvers (Zod, Yup) | Yup (built-in) |
| TypeScript | Excellent | Good |
| Learning curve | Low | Medium |
| Recommendation | ✅ Default choice | When migrating Formik codebases |

---

## Resources

- [React Hook Form Docs](https://react-hook-form.com/)
- [Formik Docs](https://formik.org/)
- [Zod Schema Validation](https://zod.dev/)

---

→ [API Integration](api-integration.md) | [Routing](routing.md) | [Phase 1 Overview](README.md)
