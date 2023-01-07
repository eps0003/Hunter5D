#include "Maths.as"
#include "Camera.as"

shared class Vec3f
{
	float x = 0;
	float y = 0;
	float z = 0;

	Vec3f(float x, float y, float z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	Vec3f(float x)
	{
		this.x = x;
		this.y = x;
		this.z = x;
	}

	Vec3f(Vec3f vec, float mag)
	{
		vec = vec.normalized();
		x = vec.x * mag;
		y = vec.y * mag;
		z = vec.z * mag;
	}

	Vec3f(Vec3f vec)
	{
		opAssign(vec);
	}

	Vec3f(float[] arr)
	{
		if (arr.size() == 3)
		{
			x = arr[0];
			y = arr[1];
			z = arr[2];
		}
		else
		{
			error("Invalid array length when initializing Vec3f: " + arr.size());
		}
	}

	void Clear()
	{
		x = 0;
		y = 0;
		z = 0;
	}

	Vec3f opAdd(const Vec3f &in vec)
	{
		return Vec3f(x + vec.x, y + vec.y, z + vec.z);
	}

	Vec3f opAdd(const float &in val)
	{
		return Vec3f(x + val, y + val, z + val);
	}

	Vec3f opSub(const Vec3f &in vec)
	{
		return Vec3f(x - vec.x, y - vec.y, z - vec.z);
	}

	Vec3f opSub(const float &in val)
	{
		return Vec3f(x - val, y - val, z - val);
	}

	Vec3f opMul(const Vec3f &in vec)
	{
		return Vec3f(x * vec.x, y * vec.y, z * vec.z);
	}

	Vec3f opMul(const float &in val)
	{
		return Vec3f(x * val, y * val, z * val);
	}

	Vec3f opDiv(const Vec3f &in vec)
	{
		return Vec3f(x / vec.x, y / vec.y, z / vec.z);
	}

	Vec3f opDiv(const float &in val)
	{
		return Vec3f(x / val, y / val, z / val);
	}

	Vec3f opMod(const float &in val)
	{
		return Vec3f(x % val, y % val, z % val);
	}

	Vec3f opNeg()
	{
		return Vec3f(x, y, z) * -1;
	}

	bool opEquals(const Vec3f &in vec)
	{
		return x == vec.x && y == vec.y && z == vec.z;
	}

	void opAssign(const Vec3f &in vec)
	{
		x = vec.x;
		y = vec.y;
		z = vec.z;
	}

	void opAddAssign(const Vec3f &in vec)
	{
		x += vec.x;
		y += vec.y;
		z += vec.z;
	}

	void opSubAssign(const Vec3f &in vec)
	{
		x -= vec.x;
		y -= vec.y;
		z -= vec.z;
	}

	void opMulAssign(const float val)
	{
		x *= val;
		y *= val;
		z *= val;
	}

	void opMulAssign(const Vec3f &in vec)
	{
		x *= vec.x;
		y *= vec.y;
		z *= vec.z;
	}

	void opDivAssign(const float val)
	{
		x /= val;
		y /= val;
		z /= val;
	}

	void opDivAssign(const Vec3f &in vec)
	{
		x /= vec.x;
		y /= vec.y;
		z /= vec.z;
	}

	void opModAssign(const float &in val)
	{
		x %= val;
		y %= val;
		z %= val;
	}

	void opModAssign(const Vec3f &in vec)
	{
		x %= vec.x;
		y %= vec.y;
		z %= vec.z;
	}

	float opIndex(const int &in index)
	{
		switch (index)
		{
			case 0: return x;
			case 1: return y;
			case 2: return z;
		}
		error("Invalid Vec3f index: " + index);
		printTrace();
		return 0;
	}

	void Print(uint precision = 3)
	{
		print(toString(precision));
	}

	string toString(uint precision = 3)
	{
		return "(" + formatFloat(x, "", 0, precision) + ", " + formatFloat(y, "", 0, precision) + ", " + formatFloat(z, "", 0, precision) + ")";
	}

	Vec3f normalized()
	{
		float lengthSq = magSquared();
		if (lengthSq == 0 || lengthSq == 1)
		{
			return this;
		}
		return this / mag();
	}

	void Normalize()
	{
		float lengthSq = magSquared();
		if (lengthSq == 0)
		{
			x = 0;
			y = 0;
			z = 0;
		}
		else if (lengthSq != 1)
		{
			float len = mag();
			x /= len;
			y /= len;
			z /= len;
		}
	}

	float mag()
	{
		return Maths::Sqrt(magSquared());
	}

	float magSquared()
	{
		return x*x + y*y + z*z;
	}

	void SetMag(float mag)
	{
		Normalize();
		x *= mag;
		y *= mag;
		z *= mag;
	}

	Vec3f dir()
	{
		float xRadians = Maths::toRadians(x);
		float yRadians = Maths::toRadians(y);
		return Vec3f(
			Maths::Sin(-yRadians) * Maths::Cos(-xRadians),
			Maths::Sin(xRadians),
			Maths::Cos(yRadians) * Maths::Cos(xRadians)
		);
	}

	Vec3f fastDir()
	{
		float xRadians = Maths::toRadians(x);
		float yRadians = Maths::toRadians(y);
		return Vec3f(
			Maths::FastSin(-yRadians) * Maths::FastCos(-xRadians),
			Maths::FastSin(xRadians),
			Maths::FastCos(yRadians) * Maths::FastCos(xRadians)
		);
	}

	Vec3f rotate(const Vec3f &in rotation)
	{
		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, rotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, rotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, rotation.z);

		float[] m;
		Matrix::Multiply(tempX, tempZ, m);
		Matrix::Multiply(m, tempY, m);

		return Vec3f(
			x*m[0] + y*m[1] + z*m[2]  + m[3],
			x*m[4] + y*m[5] + z*m[6]  + m[7],
			x*m[8] + y*m[9] + z*m[10] + m[11]
		);
	}

	float dot(const Vec3f &in vec)
	{
		return (x * vec.x) + (y * vec.y) + (z * vec.z);
	}

	Vec3f cross(const Vec3f &in vec)
	{
		return Vec3f(
			y * vec.z - z * vec.y,
			z * vec.x - x * vec.z,
			x * vec.y - y * vec.x
		);
	}

	Vec3f lerp(Vec3f desired, float t)
	{
		return this + (desired - this) * t;
	}

	Vec3f lerpAngle(Vec3f desired, float t)
	{
		return Vec3f(
			Maths::LerpAngle(x, desired.x, t),
			Maths::LerpAngle(y, desired.y, t),
			Maths::LerpAngle(z, desired.z, t)
		);
	}

	Vec3f clamp(const Vec3f &in low, const Vec3f &in high)
	{
		return Vec3f(
			Maths::Clamp2(x, low.x, high.x),
			Maths::Clamp2(y, low.y, high.y),
			Maths::Clamp2(z, low.z, high.z)
		);
	}

	Vec3f min(const Vec3f &in vec)
	{
		return Vec3f(
			Maths::Min(x, vec.x),
			Maths::Min(y, vec.y),
			Maths::Min(z, vec.z)
		);
	}

	Vec3f max(const Vec3f &in vec)
	{
		return Vec3f(
			Maths::Max(x, vec.x),
			Maths::Max(y, vec.y),
			Maths::Max(z, vec.z)
		);
	}

	float min()
	{
		return Maths::Min(Maths::Min(x, y), z);
	}

	float max()
	{
		return Maths::Max(Maths::Max(x, y), z);
	}

	Vec3f floor()
	{
		return Vec3f(
			Maths::Floor(x),
			Maths::Floor(y),
			Maths::Floor(z)
		);
	}

	Vec3f ceil()
	{
		return Vec3f(
			Maths::Ceil(x),
			Maths::Ceil(y),
			Maths::Ceil(z)
		);
	}

	Vec3f round()
	{
		return Vec3f(
			Maths::Round(x),
			Maths::Round(y),
			Maths::Round(z)
		);
	}

	Vec3f abs()
	{
		return Vec3f(
			Maths::Abs(x),
			Maths::Abs(y),
			Maths::Abs(z)
		);
	}

	Vec3f sign()
	{
		return Vec3f(
			Maths::Sign(x),
			Maths::Sign(y),
			Maths::Sign(z)
		);
	}

	float sum()
	{
		return x + y + z;
	}

	float product()
	{
		return x * y * z;
	}


	Vec2f toXZ()
	{
		return Vec2f(x, z);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_f32(x);
		bs.write_f32(y);
		bs.write_f32(z);
	}

	bool deserialize(CBitStream@ bs)
	{
		return bs.saferead_f32(x) && bs.saferead_f32(y) && bs.saferead_f32(z);
	}

	float[] toArray()
	{
		float[] arr = { x, y, z };
		return arr;
	}

	Vec3f multiply(float[] m)
	{
		return Vec3f(
			x*m[0] + y*m[4] + z*m[8]  + m[12],
			x*m[1] + y*m[5] + z*m[9]  + m[13],
			x*m[2] + y*m[6] + z*m[10] + m[14]
		);
	}

	bool isInFrontOfCamera()
	{
		Camera@ camera = Camera::getCamera();
		Vec3f posDir = this - camera.getPosition();
		Vec3f rotDir = camera.getRotation().dir();
		return posDir.dot(rotDir) >= 0;
	}

	bool isOnScreen()
	{
		if (isInFrontOfCamera())
		{
			Vec2f screenPos = projectToScreen();
			return (
				screenPos.x >= 0 &&
				screenPos.x <= getScreenWidth() &&
				screenPos.y >= 0 &&
				screenPos.y <= getScreenHeight()
			);
		}
		return false;
	}

	Vec2f projectToScreen()
	{
		Camera@ camera = Camera::getCamera();

		Vec3f vec = multiply(camera.getViewMatrix());
		vec = vec.multiply(camera.getProjectionMatrix());

		int x = ((vec.x / vec.z + 1.0f) * 0.5f) * getScreenWidth() + 0.5f;
		int y = ((1.0f - vec.y / vec.z) * 0.5f) * getScreenHeight() + 0.5f;

		return Vec2f(x, y);
	}
}
