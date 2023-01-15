#include "Vec3f.as"
#include "Maths.as"

shared class Quaternion
{
	float x = 0.0f;
	float y = 0.0f;
	float z = 0.0f;
	float w = 1.0f;

	Quaternion(float x, float y, float z, float w)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	bool opEquals(const Vec3f &in vec)
	{
		return x == vec.x && y == vec.y && z == vec.z;
	}

	Quaternion opMul(const Quaternion &in q)
	{
		return Quaternion(
			w*q.x + x*q.w + y*q.z - z*q.y,
			w*q.y - x*q.z + y*q.w + z*q.x,
			w*q.z + x*q.y - y*q.x + z*q.w,
			w*q.w - x*q.x - y*q.y - z*q.z
		);
	}

	void opMulAssign(const Quaternion &in q)
	{
		x = w*q.x + x*q.w + y*q.z - z*q.y;
		y = w*q.y - x*q.z + y*q.w + z*q.x;
		z = w*q.z + x*q.y - y*q.x + z*q.w;
		w = w*q.w - x*q.x - y*q.y - z*q.z;
	}

	Quaternion opNeg()
	{
		return inverse();
	}

	bool opEquals(const Quaternion &in q)
	{
		return x == q.x && y == q.y && z == q.z && w == q.w;
	}

	void setIdentity()
	{
		x = 0.0f;
		y = 0.0f;
		z = 0.0f;
		w = 1.0f;
	}

	float opIndex(const int &in index)
	{
		float[] arr = { x, y, z, w };
		return arr[index];
	}

	void Normalize()
	{
		float magnitudeSq = magSquared();
		if (magnitudeSq <= 0 || magnitudeSq == 1) return;

    	float invMagnitude = 1.0f / Maths::Sqrt(magnitudeSq);
		x *= invMagnitude;
		y *= invMagnitude;
		z *= invMagnitude;
		w *= invMagnitude;
	}

	Quaternion normalize()
	{
		float magnitudeSq = magSquared();
		if (magnitudeSq <= 0 || magnitudeSq == 1)
		{
			return this;
		}

    	float invMagnitude = 1.0f / Maths::Sqrt(magnitudeSq);
		return Quaternion(
			x * invMagnitude,
			y * invMagnitude,
			z * invMagnitude,
			w * invMagnitude
		);
	}

	void Scale(float scalar)
	{
		x *= scalar;
		y *= scalar;
		z *= scalar;
		w *= scalar;
	}

	Quaternion scale(float scalar)
	{
		return Quaternion(
			x * scalar,
			y * scalar,
			z * scalar,
			w * scalar
		);
	}

	void Inverse()
	{
		float magnitude = mag();
		x = -x / magnitude;
		y = -y / magnitude;
		z = -z / magnitude;
		w = w / magnitude;
	}

	Quaternion inverse()
	{
		float magnitude = mag();
		return Quaternion(
			-x / magnitude,
			-y / magnitude,
			-z / magnitude,
			w / magnitude
		);
	}

	float mag()
	{
		return Maths::Sqrt(magSquared());
	}

	float magSquared()
	{
		return x*x + y*y + z*z + w*w;
	}

	float dot(const Quaternion &in q)
	{
		return x*q.x + y*q.y + z*q.z + w*q.w;
	}

	float angleBetweenRadians(const Quaternion &in q)
	{
		float dot = this.dot(q);
		return Maths::ACos(2 * dot*dot - 1);
	}

	float angleBetweenDegrees(const Quaternion &in q)
	{
		return Maths::toDegrees(angleBetweenRadians(q));
	}

	Quaternion lerp(const Quaternion &in q, float t)
	{
		float dot = Maths::Abs(this.dot(q));
		float t1 = 1 - t;
		return Quaternion(
			t1 * x + t * q.x,
			t1 * y + t * q.y,
			t1 * z + t * q.z,
			t1 * w + t * q.w
		);
	}

	Quaternion slerp(const Quaternion &in q, float t)
	{
		float dot = Maths::Abs(this.dot(q));
		float angle = Maths::ACos(dot);
		float sinAngle = Maths::Sin(angle);
		float a = Maths::Sin((1 - t) * angle) / sinAngle;
		float b = Maths::Sin(t * angle) / sinAngle;
		return Quaternion(
			a * x + b * q.x,
			a * y + b * q.y,
			a * z + b * q.z,
			a * w + b * q.w
		);
	}

	Vec3f toEulerRadians()
	{
		return Vec3f(
			Maths::ATan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y)),
			Maths::ASin(2 * (w * y - z * x)),
			Maths::ATan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z))
		);
	}

	Vec3f toEulerDegrees()
	{
		Vec3f euler = toEulerRadians();
		return Vec3f(Maths::toDegrees(euler.x), Maths::toDegrees(euler.y), Maths::toDegrees(euler.z));
	}

	void SetFromEulerDegrees(Vec3f euler)
    {
		SetFromEulerDegrees(euler.x, euler.y, euler.z);
    }

	void SetFromEulerDegrees(float x, float y, float z)
	{
		SetFromEulerRadians(Maths::toRadians(x), Maths::toRadians(y), Maths::toRadians(z));
	}

	void SetFromEulerRadians(Vec3f euler)
    {
		SetFromEulerRadians(euler.x, euler.y, euler.z);
    }

	void SetFromEulerRadians(float x, float y, float z)
    {
        float c1 = Maths::Cos(x / 2);
        float c2 = Maths::Cos(y / 2);
        float c3 = Maths::Cos(z / 2);
        float s1 = Maths::Sin(x / 2);
        float s2 = Maths::Sin(y / 2);
        float s3 = Maths::Sin(z / 2);

        this.x = s1 * c2 * c3 + c1 * s2 * s3;
        this.y = c1 * s2 * c3 - s1 * c2 * s3;
        this.z = c1 * c2 * s3 + s1 * s2 * c3;
        this.w = c1 * c2 * c3 - s1 * s2 * s3;
    }

	void Print(uint precision = 3)
	{
		print(toString(precision));
	}

	string toString(uint precision = 3)
	{
		return "(" + formatFloat(x, "", 0, precision) + ", " + formatFloat(y, "", 0, precision) + ", " + formatFloat(z, "", 0, precision) + ", " + formatFloat(w, "", 0, precision) + ")";
	}
}
