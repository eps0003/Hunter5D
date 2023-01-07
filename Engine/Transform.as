#include "Vec3f.as"

shared class Transform
{
	private Vec3f position;
	private Vec3f rotation;
	private Vec3f scale;

	Transform(Vec3f position = Vec3f(), Vec3f rotation = Vec3f(), Vec3f scale = Vec3f())
	{
		this.position = position;
		this.rotation = rotation;
		this.scale = scale;
	}

	Transform(Transform transform)
	{
		opAssign(transform);
	}

	bool opEquals(const Transform &in transform)
	{
		return (
			position == transform.position &&
			rotation == transform.rotation &&
			scale == transform.scale
		);
	}

	void opAssign(const Transform &in transform)
	{
		position = transform.position;
		rotation = transform.rotation;
		scale = transform.scale;
	}

	void Print(uint precision = 3)
	{
		print(toString(precision));
	}

	string toString(uint precision = 3)
	{
		return "Position: " + position.toString(precision)
			+ "; Rotation: " + rotation.toString(precision)
			+ "; Scale: " + scale.toString(precision);
	}

	Vec3f getPosition()
	{
		return position;
	}

	void SetPosition(Vec3f position)
	{
		this.position = position;
	}

	void SetPosition(float x, float y, float z)
	{
		SetPosition(Vec3f(x, y, z));
	}

	Vec3f getRotation()
	{
		return rotation;
	}

	void SetRotation(Vec3f rotation)
	{
		this.rotation = rotation;
	}

	void SetRotation(float x, float y, float z)
	{
		SetRotation(Vec3f(x, y, z));
	}

	Vec3f getScale()
	{
		return scale;
	}

	void SetScale(Vec3f scale)
	{
		this.scale = scale;
	}

	void SetScale(float x, float y, float z)
	{
		SetScale(Vec3f(x, y, z));
	}

	void Translate(Vec3f translation)
	{
		this.position += translation;
	}

	void Translate(float x, float y, float z)
	{
		Translate(Vec3f(x, y, z));
	}

	void Rotate(Vec3f rotation)
	{
		this.rotation += rotation;
	}

	void Rotate(float x, float y, float z)
	{
		Rotate(Vec3f(x, y, z));
	}

	void Scale(Vec3f scale)
	{
		this.scale += scale;
	}

	void Scale(float x, float y, float z)
	{
		Scale(Vec3f(x, y, z));
	}

	void Serialize(CBitStream@ bs)
	{
		position.Serialize(bs);
		rotation.Serialize(bs);
		scale.Serialize(bs);
	}

	bool deserialize(CBitStream@ bs)
	{
		return (
			position.deserialize(bs) &&
			rotation.deserialize(bs) &&
			scale.deserialize(bs)
		);
	}
}
