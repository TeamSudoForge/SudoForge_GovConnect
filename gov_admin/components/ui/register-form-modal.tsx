import RegisterPage from "@/app/auth/register/page";

export default function RegisterFormModal({ onClose }: { onClose: () => void }) {
  return <RegisterPage isModal onClose={onClose} />;
}
