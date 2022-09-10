#include "ModelSegment.as"
#include "Interpolation.as"
#include "CMatrix.as"
#include "Animation.as"

shared class Model
{
	float scale = 1.0f;

	private CMatrix matrix;

	private dictionary segments;
	private ModelSegment@ rootSegment;

	private ModelAnimation@ animation;

	Model(float scale)
	{
		this.scale = scale;
	}

	ModelSegment@ AddSegment(string name, string modelPath, string texture)
	{
		return AddSegment(name, ModelSegment(modelPath, texture));
	}

	ModelSegment@ AddSegment(string name, ModelSegment@ segment)
	{
		if (segments.exists(name))
		{
			error("Attempted to add model segment with name that is already in use: " + name);
			printTrace();
			return segment;
		}

		if (segments.isEmpty())
		{
			SetRootSegment(segment);
		}

		segments.set(name, @segment);
		return segment;
	}

	void SetRootSegment(ModelSegment@ segment)
	{
		@rootSegment = segment;
	}

	ModelSegment@ getSegment(string name)
	{
		ModelSegment@ segment;
		segments.get(name, @segment);
		return segment;
	}

	void SetAnimation(ModelAnimation@ animation)
	{
		@this.animation = animation;
	}

	void Render()
	{
		if (animation !is null)
		{
			float t = (Interpolation::getGameTime() / getTicksASecond()) % 1.0f;
			animation.Animate(t);
		}

		CMatrix scaleMatrix;
		scaleMatrix.SetScale(scale);
		matrix *= scaleMatrix;

		rootSegment.Render(matrix, Interpolation::getFrameTime());
	}
}